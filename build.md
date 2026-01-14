Проект hw-core: напоминание и инструкция для будущей работы

Цель проекта
------------
- hw_core — ядро мессенджера с E2E-шифрованием (Rust).
- cpp_client — десктопный клиент на C++/Qt, который:
  - использует Rust-ядро через FFI для крипты;
  - общается с Supabase (REST) как с «тупым» почтовым ящиком;
  - позволяет двум пользователям писать друг другу с зашифрованными сообщениями.

Архитектура в одном абзаце
--------------------------
- Rust crate `hw_core`:
  - модуль `crypto`: генерация ключей (X25519), HKDF, ChaCha20-Poly1305;
  - модуль `models`: UserId/ChatId/MessageId, CoreMessage, статусы доставки;
  - модуль `ffi`: чистые C-функции, которые вызываются из C++ (генерация ключей, derive shared secret, encrypt/decrypt).
- C++/Qt клиент:
  - слой Supabase (`supabase_client.[h|cpp]`): простые HTTP-запросы к таблицам `users` и `messages`;
  - слой UI (`mainwindow.[h|cpp]`): экраны регистрации и чата, таймер опроса Supabase;
  - для каждого окна:
    - при регистрации создаётся пользователь + публикуется публичный ключ в Supabase;
    - при подключении к собеседнику берётся его публичный ключ → E2E-общий секрет через Rust;
    - сообщения шифруются/расшифровываются только на клиенте.

Важно про ключи и конфиг
------------------------
- Никогда не коммитить реальные Supabase-ключи в репозиторий.
- Для клиента используется только anon/public key.
- Файл `cpp_client/supabase_config.h`:
  - `supabaseUrl()` — URL проекта Supabase;
  - `supabaseAnonKey()` — anon key.
- Эти значения заполняются ЛОКАЛЬНО и не должны попадать в общий репо.

Сборка Rust-ядра
----------------
```bash
cd c:\Users\lario\Desktop\hw-core
cargo build --release
```

Сборка Qt-клиента (общая схема)
-------------------------------
1. Qt должен быть установлен как SDK (через Qt Online Installer).
2. Нужен путь к установленному Qt, например:
   - `C:/Qt/6.7.2/msvc2022_64` или `C:/Qt/6.7.2/mingw_64`.
3. Конфигурация и сборка:

```bash
cd c:\Users\lario\Desktop\hw-core

cmake -S cpp_client -B cpp_client/build ^
  -DCMAKE_PREFIX_PATH="C:/Qt/6.7.2/msvc2022_64"

cmake --build cpp_client/build --config Release
```

Путь в `CMAKE_PREFIX_PATH` нужно заменить на реальный путь до установленного Qt (папка, внутри которой есть `lib/cmake/Qt6/Qt6Config.cmake`).

Как запускать и тестировать
---------------------------
1. Заполнить `supabase_config.h` корректным `supabaseUrl()` и `supabaseAnonKey()`.
2. Убедиться, что в Supabase есть таблицы:
   - `public.users` (username, display_name, public_key_base64);
   - `public.messages` (chat_id, sender_username, encrypted_payload_base64, id, created_at).
3. Собрать `hw_desktop_client`.
4. Запустить две копии `hw_desktop_client.exe`:
   - в первом окне зарегистрировать, например, `user1`;
   - во втором — `user2`;
   - в обоих указать username собеседника и нажать «Подключиться».
5. При отправке сообщения:
   - текст шифруется в Rust;
   - зашифрованный payload уходит в Supabase;
   - второе окно опрашивает Supabase, расшифровывает и показывает сообщение.

# сборка:
powershell -ExecutionPolicy Bypass -File build_client.ps1 -Config Release
# потом:
cpp_client/build/Release/hw_desktop_client.exe