# HelloWorld — Мессенджер с E2E-шифрованием

## Цель проекта
- **helloworld_core** — криптографическое ядро на Rust.
- **ios_client** — мобильное приложение на SwiftUI (стиль Telegram Dark Mode).

## Архитектура
1. **Rust Core**:
   - Криптография: X25519, HKDF, ChaCha20-Poly1305.
   - FFI: Интерфейс для вызова из Swift.
2. **iOS Client**:
   - UI: SwiftUI.
   - Связь: CoreWrapper.swift вызывает Rust через Bridging Header.
   - Бэкенд: Supabase (REST/Realtime) для обмена зашифрованными данными.

## Сборка для iOS (Unsigned IPA)

Сборка осуществляется через **Codemagic**.

1. Закоммитьте изменения в репозиторий.
2. В Codemagic выберите workflow `HelloWorld iOS Unsigned Build`.
3. После завершения скачайте `HelloWorld.ipa`.

### Локальная генерация проекта Xcode
Если у вас есть macOS, вы можете сгенерировать проект локально:
```bash
gem install xcodeproj
ruby generate_project.rb
```

## Криптография
Все сообщения шифруются на стороне клиента. Приватные ключи никогда не покидают устройство.
Общий секрет вычисляется на лету между двумя пользователями по их публичным ключам.
