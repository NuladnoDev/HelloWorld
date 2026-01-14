import { Search, Archive } from 'lucide-react';
import { useState } from 'react';

interface Chat {
  id: number;
  name: string;
  lastMessage: string;
  time: string;
  avatar: string;
  unread?: number;
  online?: boolean;
  pinned?: boolean;
}

const mockChats: Chat[] = [
  {
    id: 1,
    name: 'Archived chats',
    lastMessage: 'Контент: вектор разговоров и Черновики лейбл: Telegram Гео:Российская Элитная...',
    time: '',
    avatar: '',
    pinned: true,
  },
  {
    id: 2,
    name: 'AI СШ 1',
    lastMessage: 'Видение галереи. Миссия: выполнения',
    time: '18:04',
    avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop',
    unread: 2,
  },
  {
    id: 3,
    name: 'zoparatius',
    lastMessage: 'Только что я сказал, что делаю вид что с+',
    time: '16:24',
    avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
  },
  {
    id: 4,
    name: 'kikka',
    lastMessage: 'Photo',
    time: '16:20',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
  },
  {
    id: 5,
    name: 'a',
    lastMessage: '🔥',
    time: '22:42',
    avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop',
  },
  {
    id: 6,
    name: 'ancor 🔧',
    lastMessage: 'Видела',
    time: 'Вчера',
    avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop',
  },
  {
    id: 7,
    name: 'Saved Messages',
    lastMessage: 'https://t.me/telegram-update/147',
    time: 'Пон',
    avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop',
  },
  {
    id: 8,
    name: 'Paster',
    lastMessage: 'Такой вариант не подал прада 25:48',
    time: 'Пон',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop',
    online: true,
  },
];

interface ChatListProps {
  onSelectChat: (chat: Chat) => void;
  selectedChatId?: number;
}

export function ChatList({ onSelectChat, selectedChatId }: ChatListProps) {
  const [searchQuery, setSearchQuery] = useState('');

  return (
    <div className="w-[380px] bg-white flex flex-col border-r border-gray-200">
      {/* Search Bar */}
      <div className="p-2">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
          <input
            type="text"
            placeholder="Поиск"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 bg-gray-100 rounded-full outline-none focus:bg-white focus:ring-1 focus:ring-blue-400 transition-all"
          />
        </div>
      </div>

      {/* Chat List */}
      <div className="flex-1 overflow-y-auto">
        {mockChats.map((chat) => (
          <div
            key={chat.id}
            onClick={() => onSelectChat(chat)}
            className={`flex items-center gap-3 p-3 cursor-pointer hover:bg-gray-50 transition-colors ${
              selectedChatId === chat.id ? 'bg-blue-50' : ''
            }`}
          >
            {/* Avatar */}
            <div className="relative flex-shrink-0">
              {chat.id === 1 ? (
                <div className="w-12 h-12 rounded-full bg-gray-200 flex items-center justify-center">
                  <Archive size={20} className="text-gray-600" />
                </div>
              ) : (
                <img
                  src={chat.avatar}
                  alt={chat.name}
                  className="w-12 h-12 rounded-full object-cover"
                />
              )}
              {chat.online && (
                <div className="absolute bottom-0 right-0 w-3 h-3 bg-[#0088cc] rounded-full border-2 border-white"></div>
              )}
            </div>

            {/* Chat Info */}
            <div className="flex-1 min-w-0">
              <div className="flex items-baseline justify-between mb-1">
                <h3 className="font-medium text-[15px] text-gray-900 truncate">
                  {chat.name}
                </h3>
                {chat.time && (
                  <span className={`text-xs ml-2 flex-shrink-0 ${
                    chat.unread ? 'text-[#0088cc]' : 'text-gray-500'
                  }`}>
                    {chat.time}
                  </span>
                )}
              </div>
              <div className="flex items-center justify-between">
                <p className="text-sm text-gray-500 truncate flex-1">
                  {chat.lastMessage}
                </p>
                {chat.unread && (
                  <div className="ml-2 min-w-[20px] h-5 px-1.5 bg-[#0088cc] text-white text-xs rounded-full flex items-center justify-center">
                    {chat.unread}
                  </div>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
