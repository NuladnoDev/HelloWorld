use serde::{Deserialize, Serialize};

use super::ids::{ChatId, MessageId, UserId};

// Статус доставки сообщения — примерно как в Telegram.
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
pub enum MessageDeliveryStatus {
    Sending,
    SentToServer,
    DeliveredToPeer,
    Read,
}

// Модель сообщения в ядре: здесь хранится только зашифрованный payload.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CoreMessage {
    pub id: MessageId,
    pub chat_id: ChatId,
    pub sender_id: UserId,
    pub encrypted_payload_base64: String,
    pub created_at_ms: i64,
    pub status: MessageDeliveryStatus,
}
