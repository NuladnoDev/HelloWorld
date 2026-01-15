use serde::{Deserialize, Serialize};

use super::ids::UserId;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CoreUser {
    pub id: UserId,
    pub display_name: String,
    pub public_key_base64: String,
    pub tag: Option<String>,
    pub phone_number: Option<String>,
    pub avatar_base64: Option<String>,
}

