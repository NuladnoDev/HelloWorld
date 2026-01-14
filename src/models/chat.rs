use serde::{Deserialize, Serialize};

use super::ids::{ChatId, UserId};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CoreChat {
    pub id: ChatId,
    pub participant_user_ids: Vec<UserId>,
}

