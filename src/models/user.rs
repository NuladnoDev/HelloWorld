use serde::{Deserialize, Serialize};

use super::ids::UserId;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CoreUser {
    pub id: UserId,
    pub display_name: String,
    pub public_key_base64: String,
}

