# HelloWorld — инструкция для следующей нейросети по проекту

Этот файл объясняет, как устроен проект `HelloWorld`: его Rust‑ядро, iOS‑клиент, интеграция с Supabase.

Основная цель: чтобы другая модель могла быстро въехать в архитектуру и безопасно вносить изменения.

---

## 1. Общая архитектура

Проект представляет собой end‑to‑end зашифрованный мини‑мессенджер:

- **Rust‑crate `helloworld_core`** — криптографическое ядро:
  - генерация долгоживущих identity‑ключей (X25519);
  - вычисление общего секрета между двумя пользователями;
  - derivation отдельного симметричного ключа на каждый чат через HKDF;
  - шифрование/дешифрование сообщений ChaCha20‑Poly1305 с AAD;
  - FFI‑слой для вызова из Swift.
- **iOS‑клиент `ios_client`**:
  - UI‑слой на SwiftUI (регистрация и чат) в стиле Telegram (Dark Mode);
  - обёртка над Rust‑ядром через `CoreWrapper.swift` и Bridging Header.
- **Supabase** используется только как «тупое хранилище»:
  - таблица `public.users` — хранит публичные ключи и имена;
  - таблица `public.messages` — хранит только зашифрованные payload’ы;
  - RLS настроены так, чтобы `anon` (публичный) клиент мог:
    - создавать пользователей;
    - писать/читать сообщения только по конкретному `chat_id`.

Все важные секреты (приватные ключи пользователей и общий секрет чата) живут только на клиенте.

---

## 2. Структура репозитория

Корень: `c:\Users\lario\Desktop\hw-core`

- Rust‑ядро:
  - [src/lib.rs](file:///c:/Users/lario/Desktop/hw-core/src/lib.rs)
  - [src/ffi.rs](file:///c:/Users/lario/Desktop/hw-core/src/ffi.rs)
  - [src/crypto/crypto_service.rs](file:///c:/Users/lario/Desktop/hw-core/src/crypto/crypto_service.rs)
  - [src/crypto/key_manager.rs](file:///c:/Users/lario/Desktop/hw-core/src/crypto/key_manager.rs)
  - [src/models](file:///c:/Users/lario/Desktop/hw-core/src/models)
- C++/Qt‑клиент:
  - [cpp_client/main.cpp](file:///c:/Users/lario/Desktop/hw-core/cpp_client/main.cpp)
  - [cpp_client/mainwindow.h](file:///c:/Users/lario/Desktop/hw-core/cpp_client/mainwindow.h)
  - [cpp_client/mainwindow.cpp](file:///c:/Users/lario/Desktop/hw-core/cpp_client/mainwindow.cpp)
  - [cpp_client/supabase_client.h](file:///c:/Users/lario/Desktop/hw-core/cpp_client/supabase_client.h)
  - [cpp_client/supabase_client.cpp](file:///c:/Users/lario/Desktop/hw-core/cpp_client/supabase_client.cpp)
  - [cpp_client/rust_core.h](file:///c:/Users/lario/Desktop/hw-core/cpp_client/rust_core.h)
  - [cpp_client/supabase_config.h](file:///c:/Users/lario/Desktop/hw-core/cpp_client/supabase_config.h)
  - [cpp_client/CMakeLists.txt](file:///c:/Users/lario/Desktop/hw-core/cpp_client/CMakeLists.txt)
- Сборка:
  - [build_client.ps1](file:///c:/Users/lario/Desktop/hw-core/build_client.ps1) — единая команда для сборки ядра и Qt‑клиента.
  - [build.md](file:///c:/Users/lario/Desktop/hw-core/build.md) — краткая инструкция по сборке (для человека).

---

## 3. Криптоядро (Rust `hw_core`)

### 3.1. Генерация identity‑ключей

Код: [src/crypto/key_manager.rs](file:///c:/Users/lario/Desktop/hw-core/src/crypto/key_manager.rs)

Основная сущность — `IdentityKeyPair`:

- приватный ключ: `x25519_dalek::StaticSecret`;
- публичный ключ: `x25519_dalek::PublicKey`.

`KeyManager::generate_identity_keypair()`:

- генерирует новый приватный ключ через `StaticSecret::new(OsRng)`;
- получает публичный через `PublicKey::from(&private)`.

Экспорт/импорт:

- `export_private_key_base64` — кодирует 32 байта приватного ключа в base64‑строку;
- `import_private_key_base64` — обратная операция (base64 → 32 байта → `StaticSecret`);
- `public_key_base64` — публичный ключ в base64 (чтобы отправить в Supabase);
- `public_key_from_base64` — восстановление `PublicKey` из base64.

### 3.2. Общий секрет и ключ чата

Код: [src/crypto/crypto_service.rs](file:///c:/Users/lario/Desktop/hw-core/src/crypto/crypto_service.rs)

1. **Общий секрет** (`derive_shared_secret` / `derive_shared_secret_from_identities`):
   - вход: приватный ключ пользователя + публичный ключ собеседника;
   - алгоритм: стандартный X25519 Diffie–Hellman;
   - выход: 32 байта общего секрета `shared_secret`.
2. **Ключ чата** (`derive_chat_key`):
   - вход: `shared_secret` (32 байта) и `ChatId` (строка вида `"userA:userB"`);
   - алгоритм: HKDF‑SHA256:
     - salt = `chat_id.as_bytes()`;
     - info = `"chat-key"`;
   - выход: `ChatKey([u8; 32])` — симметричный ключ для этого чата.

Таким образом, один и тот же общий секрет может использоваться для разных чатов, но ключ чата будет зависеть от `chat_id`.

### 3.3. Шифрование/дешифрование сообщений

Код: [src/crypto/crypto_service.rs](file:///c:/Users/lario/Desktop/hw-core/src/crypto/crypto_service.rs)

Алгоритм: `ChaCha20Poly1305` с дополнительными данными (AAD).

- При шифровании:
  - генерируется случайный `nonce` (12 байт) через `getrandom`;
  - AAD = строка `"{chat_id}|{sender_id}"`;
  - шифруется текст, к шифртексту добавляется тег аутентичности;
  - итог: `nonce || ciphertext+tag`, всё вместе кодируется в base64 (`encrypted_payload_base64`).
- При расшифровке:
  - строка base64 → массив байт;
  - отделяется первые 12 байт как `nonce`;
  - строится тот же AAD `"{chat_id}|{sender_id}"`;
  - вызывается `decrypt` с тем же ключом чата и AAD;
  - при любой несостыковке (ключ, AAD, повреждённые данные) расшифровка падает с ошибкой.

Важно: `sender_id` в AAD — это логический идентификатор пользователя (в клиенте берётся `username`).

### 3.4. FFI‑слой

Код: [src/ffi.rs](file:///c:/Users/lario/Desktop/hw-core/src/ffi.rs), заголовок в C++: [cpp_client/rust_core.h](file:///c:/Users/lario/Desktop/hw-core/cpp_client/rust_core.h)

Экспортируются функции:

- `hw_generate_identity_keypair(char** out_private_b64, char** out_public_b64)`  
  Генерирует новую пару ключей и возвращает base64‑строки приватного и публичного ключей.
- `hw_derive_shared_secret(const char* my_private_b64, const char* peer_public_b64, char** out_shared_b64)`  
  Восстанавливает пару из приватного ключа, публичный ключ собеседника и считает общий секрет, возвращая base64(32 байта).
- `hw_encrypt_message(const char* shared_b64, const char* chat_id, const char* sender_id, const char* plaintext, char** out_encrypted_b64)`  
  Декодирует `shared_b64`, выводит base64(nonce || ciphertext+tag).
- `hw_decrypt_message(const char* shared_b64, const char* chat_id, const char* sender_id, const char* encrypted_b64, char** out_plaintext)`  
  Обратная операция, возвращает расшифрованный текст.
- `hw_free_string(char* s)` — освобождение C‑строк, выделенных внутри Rust.

Все строки в FFI — UTF‑8, обёрнутые в `CString`.

---

## 4. Qt‑клиент (C++/Qt)

### 4.1. Конфиг Supabase и ключи

Файл: [cpp_client/supabase_config.h](file:///c:/Users/lario/Desktop/hw-core/cpp_client/supabase_config.h)

Здесь заданы две функции:

- `supabaseUrl()` — URL проекта Supabase (`https://xxxxx.supabase.co`);
- `supabaseAnonKey()` — publishable (anon) ключ из Supabase.

Где взять значения:

- Supabase Dashboard → **Project Settings → API**:
  - `Project URL` → для `supabaseUrl()`;
  - `anon/public API key` → для `supabaseAnonKey()`.

Важно:

- использовать только **anon/public key**, не service‑role;
- реальные ключи должны заполняться **локально** и не коммититься в публичный репозиторий.

### 4.2. HTTP‑клиент Supabase

Файлы:

- [cpp_client/supabase_client.h](file:///c:/Users/lario/Desktop/hw-core/cpp_client/supabase_client.h)
- [cpp_client/supabase_client.cpp](file:///c:/Users/lario/Desktop/hw-core/cpp_client/supabase_client.cpp)

Основные методы:

- `registerUser(username, displayName, publicKeyBase64, error)`:
  - POST `/rest/v1/users` с JSON:
    - `username`
    - `display_name`
    - `public_key_base64`
  - заголовки:
    - `apikey: <anon>`
    - `Authorization: Bearer <anon>`
    - `Prefer: return=representation`
- `fetchUserPublicKey(username, &outPublicKey, &error)`:
  - GET `/rest/v1/users` с query:
    - `username=eq.<username>`
    - `select=public_key_base64`
    - `limit=1`
- `sendMessage(chatId, senderUsername, encryptedPayloadBase64, error)`:
  - POST `/rest/v1/messages` с JSON:
    - `chat_id`
    - `sender_username`
    - `encrypted_payload_base64`
- `fetchMessagesSince(chatId, lastMessageId, &outMessages, &error)`:
  - GET `/rest/v1/messages`:
    - `chat_id=eq.<chatId>`
    - `id=gt.<lastMessageId>` (если `lastMessageId > 0`)
    - `order=id.asc`

Во всех запросах используется `QNetworkAccessManager` с отключённым системным прокси (`setProxy(QNetworkProxy::NoProxy)`), чтобы не ловить ошибки вида «Host requires authentication».

### 4.3. Realtime (Supabase Realtime через WebSocket)

В том же `SupabaseClient`:

- при конструировании формируется `m_realtimeUrl`:
  - `https://` → `wss://`, `http://` → `ws://`;
  - добавляется `/realtime/v1/websocket?apikey=<anon>&vsn=1.0.0`.
- `subscribeRealtimeMessages(chatId)`:
  - создаёт `QWebSocket` (если ещё нет);
  - открывает соединение на `m_realtimeUrl`;
  - после `connected` вызывает `sendRealtimeJoin()`.
- `sendRealtimeJoin()`:
  - шлёт `phx_join` на топик `realtime:public:messages` с payload:
    - `schema: "public"`
    - `table: "messages"`
    - `events: ["INSERT"]`
    - `filter: "chat_id=eq.<chatId>"`
- `onRealtimeTextMessage(msg)`:
  - парсит JSON ответа Realtime;
  - берёт `payload.record`:
    - `id`
    - `chat_id`
    - `sender_username`
    - `encrypted_payload_base64`
  - эмитит сигнал:
    - `realtimeMessageReceived(id, chatId, sender, encrypted)`.

Параллельно работает резервный опрос (polling) через HTTP с таймером (по умолчанию 30 секунд) — он нужен как fallback, если Realtime отвалится. Чтобы не было дублей сообщений, обработчик Realtime обновляет `m_lastMessageId`.

### 4.4. Основное окно и UX

Файлы:

- [cpp_client/mainwindow.h](file:///c:/Users/lario/Desktop/hw-core/cpp_client/mainwindow.h)
- [cpp_client/mainwindow.cpp](file:///c:/Users/lario/Desktop/hw-core/cpp_client/mainwindow.cpp)

Компоненты:

- `m_registerPage` — страница регистрации:
  - поля `m_usernameEdit`, `m_displayNameEdit`;
  - кнопка «Зарегистрироваться».
- `m_chatPage` — страница чата:
  - поле `m_peerEdit` (username собеседника) + кнопка «Подключиться»;
  - список сообщений `m_messageList`;
  - поле ввода `m_messageEdit` + кнопка «Отправить».
- состояние:
  - `m_username`, `m_displayName`;
  - `m_privateKeyB64`, `m_publicKeyB64`;
  - `m_sharedSecretB64`;
  - `m_peerUsername`, `m_chatId`, `m_lastMessageId`.

Основные сценарии:

#### Регистрация (`onRegisterClicked`)

1. Проверяет, что поля username и display name не пустые.
2. Вызывает `hw_generate_identity_keypair`:
   - получает `m_privateKeyB64` и `m_publicKeyB64`.
3. Через `SupabaseClient::registerUser` создаёт запись в `public.users`.
4. Показывает системное сообщение и переключается на страницу чата.

Приватный ключ живёт только в памяти клиента (`m_privateKeyB64`), публичный отправляется в Supabase.

#### Подключение к собеседнику (`onConnectPeerClicked`)

1. Берёт `peerUsername` из `m_peerEdit`.
2. Через `SupabaseClient::fetchUserPublicKey` получает `peerPublicKey`.
3. Вызывает `hw_derive_shared_secret(m_privateKeyB64, peerPublicKey)`:
   - результат сохраняется в `m_sharedSecretB64`.
4. Строит `m_chatId` как `min(username1, username2) + ":" + max(...)`:
   - это важно: обе стороны должны получить одинаковый `chat_id`.
5. Обнуляет `m_lastMessageId`.
6. Пишет системное сообщение «Подключено к чату».
7. Запускает `m_pollTimer` (30 секунд) и вызывает `m_supabase->subscribeRealtimeMessages(m_chatId)`.

#### Отправка сообщения (`onSendClicked`)

1. Проверяет, что текст не пуст и `m_sharedSecretB64`/`m_chatId` заполнены.
2. Берёт:
   - `shared = m_sharedSecretB64`;
   - `chat_id = m_chatId`;
   - `sender_id = m_username`.
3. Вызывает `hw_encrypt_message(shared, chat_id, sender_id, plaintext)`:
   - получает `encryptedB64`.
4. Через `SupabaseClient::sendMessage` пишет запись в `public.messages`.
5. Локально добавляет расшифрованное сообщение от себя в `m_messageList`.

#### Получение сообщений (polling) (`onPollTimer`)

1. Запрашивает через `fetchMessagesSince(m_chatId, m_lastMessageId)` новые записи.
2. Для каждой записи:
   - обновляет `m_lastMessageId`;
   - пропускает, если `sender_username == m_username` (свои сообщения уже показаны локально);
   - вызывает `hw_decrypt_message(shared, chat_id, sender_id, encrypted)` и добавляет в UI.

#### Получение сообщений (Realtime) (`onRealtimeMessage`)

Сигнал из `SupabaseClient`:

- вход: `id`, `chatId`, `sender`, `encryptedB64`.

Алгоритм:

1. Если `chatId != m_chatId` или нет `m_sharedSecretB64` — игнор.
2. Обновляет `m_lastMessageId = max(m_lastMessageId, id)` (важно для избежания дублей с polling).
3. Если `sender == m_username` — игнор (свои сообщения показаны сразу).
4. Вызывает `hw_decrypt_message(shared, chat_id, sender_id, encrypted)` и добавляет сообщение в UI.

---

## 5. Supabase: таблицы, RLS и Realtime

### 5.1. Таблица `public.users`

Минимальная схема (логическая):

- `id` (uuid, по желанию);
- `username` (text, уникальный);
- `display_name` (text);
- `public_key_base64` (text, 44 символа для X25519‑ключа).

Использование:

- при регистрации создаётся запись с новым `username` и публичным ключом;
- при подключении к собеседнику берётся `public_key_base64` по `username`.

### 5.2. Таблица `public.messages`

Минимальная схема:

- `id` (bigint, автоинкремент, PK);
- `chat_id` (text);
- `sender_username` (text);
- `encrypted_payload_base64` (text);
- `created_at` (timestamp with time zone, default now()).

Использование:

- клиент пишет в эту таблицу через REST/anon key;
- читает только по конкретному `chat_id` и `id > lastMessageId`.

### 5.3. RLS (общая идея)

RLS‑политики должны:

- разрешать вставку в `users` и `messages` для `anon` (или публичной роли, привязанной к твоему ключу);
- разрешать селект:
  - `users`: либо всем, либо по `username`;
  - `messages`: только по `chat_id` (или ещё дополнительно по `sender_username`, но это не обязательно).

Важно: в проекте всё сделано под **публичный клиент** с anon key, без авторизации пользователей Supabase.

### 5.4. Realtime‑канал

Supabase Realtime отслеживает INSERT’ы в `public.messages`. Клиент подписывается на канал:

- topic: `realtime:public:messages`;
- filter: `chat_id=eq.<chatId>`.

Все новые сообщения для этого `chatId` прилетают в WebSocket, и клиент их расшифровывает.

---

## 6. Сборка и запуск

### 6.1. Сборка Rust‑ядра

Команда (из корня проекта):

```bash
cargo build --release
```

Результат: `target/release/hw_core.dll` (плюс прочие артефакты).

### 6.2. Сборка и деплой Qt‑клиента

Рекомендуемый способ — через PowerShell‑скрипт [build_client.ps1](file:///c:/Users/lario/Desktop/hw-core/build_client.ps1).

Внутри он делает:

1. `cargo build --release` — собирает Rust‑ядро;
2. `cmake -S cpp_client -B cpp_client/build -DCMAKE_PREFIX_PATH="<QtPath>"` (однократно);
3. `cmake --build cpp_client/build --config Release` — собирает `hw_desktop_client.exe`;
4. запускает `windeployqt` для подтягивания нужных Qt‑DLL (включая `Qt6WebSockets.dll`);
5. копирует `target/release/hw_core.dll` в `cpp_client/build/Release`.

Запуск:

```powershell
powershell -ExecutionPolicy Bypass -File build_client.ps1 -Config Release
cpp_client/build/Release/hw_desktop_client.exe
```

Qt‑путь (`$QtPath`) в скрипте нужно подставить под локальную установку Qt.

---

## 7. Важные инварианты и правила для следующей нейросети

1. **Не ломать криптоинварианты:**
   - `chat_id` должен строиться симметрично на обоих клиентах (`min + ":" + max`);
   - при шифровании/дешифровании AAD всегда `"{chat_id}|{sender_id}"`;
   - длина общего секрета строго 32 байта.
2. **Не трогать формат FFI без необходимости:**
   - все FFI‑функции работают с UTF‑8 и base64‑строками;
   - если меняешь сигнатуру в Rust, синхронизируй [rust_core.h](file:///c:/Users/lario/Desktop/hw-core/cpp_client/rust_core.h) и вызовы в C++.
3. **Ключи Supabase:**
   - использовать только anon/public key;
   - `supabaseUrl()` и `supabaseAnonKey()` должны оставаться простыми функциями, возвращающими строки;
   - реальные значения не коммитить.
4. **Realtime + polling:**
   - `realtimeMessageReceived` должен обновлять `m_lastMessageId`, чтобы polling не дублировал сообщения;
   - `onPollTimer` и Realtime должны использовать один и тот же формат `SupabaseMessage`/JSON.
5. **UI‑логика:**
   - расшифровка всегда происходит только на клиенте;
   - свои отправленные сообщения отображаются сразу (без ожидания Supabase);
   - входящие сообщения показываются только после успешной расшифровки.

Если будешь добавлять новые фичи (типы сообщений, статусы, истории чатов), старайся:

- не хранить в Supabase ничего, что раскрывает содержимое переписки;
- добавлять поля либо как метаданные (не влияющие на криптографию), либо аккуратно согласовывать их с ядром.

На этом всё: этого файла должно хватить, чтобы другая модель уверенно ориентировалась в проекте и не разломала безопасность. 

