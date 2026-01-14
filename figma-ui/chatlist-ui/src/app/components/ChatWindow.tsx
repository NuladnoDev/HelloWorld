import { Search, Phone, MoreVertical, Smile, Paperclip, Mic } from 'lucide-react';
import { Message } from './Message';
import { useState } from 'react';

interface Chat {
  id: number;
  name: string;
  lastMessage: string;
  time: string;
  avatar: string;
  unread?: number;
  online?: boolean;
}

interface MessageData {
  id: number;
  text: string;
  time: string;
  isOutgoing: boolean;
  isRead?: boolean;
}

interface ChatWindowProps {
  chat: Chat;
}

const mockMessages: MessageData[] = [
  { id: 1, text: 'Дарова', time: '15:33', isOutgoing: false },
  { id: 2, text: 'Да, давай', time: '15:33', isOutgoing: false },
  { id: 3, text: 'Мемы', time: '15:37', isOutgoing: false },
  { id: 4, text: 'Иди', time: '15:37', isOutgoing: false },
  { id: 5, text: 'Давай', time: '15:37', isOutgoing: false },
  { 
    id: 6, 
    text: 'Tr зажрешься за читабельт на минус 15-15 час. через это важное обижает дуть экстазис', 
    time: '15:42', 
    isOutgoing: true,
    isRead: true 
  },
  { 
    id: 7, 
    text: 'Ну послужало тогда отлажалась не да там', 
    time: '15:53', 
    isOutgoing: false 
  },
  { 
    id: 8, 
    text: 'Ну через время та поволоку загнитить долевки', 
    time: '15:53', 
    isOutgoing: false 
  },
  { 
    id: 9, 
    text: 'Врашэн стандарт что за час, ни им особенний слышать', 
    time: '15:57', 
    isOutgoing: true,
    isRead: true 
  },
  { 
    id: 10, 
    text: 'Да', 
    time: '15:57', 
    isOutgoing: false 
  },
  { 
    id: 11, 
    text: 'Пу через време та по...', 
    time: '16:03', 
    isOutgoing: false 
  },
  { 
    id: 12, 
    text: 'Вяжыч стандарт что за час 90 ч', 
    time: '16:04', 
    isOutgoing: false 
  },
  { 
    id: 13, 
    text: 'Не всяким читя да стой', 
    time: '16:06', 
    isOutgoing: false 
  },
  { 
    id: 14, 
    text: 'Ну ми найревіт кто документа до этого', 
    time: '16:06', 
    isOutgoing: false 
  },
  { 
    id: 15, 
    text: 'Все знакомые здраво разбернутр дальше', 
    time: '17:26', 
    isOutgoing: true,
    isRead: true 
  },
  { 
    id: 16, 
    text: 'Спасибо за народну', 
    time: '17:26', 
    isOutgoing: false 
  },
  { 
    id: 17, 
    text: 'Учет обманах читая не один выходит не створюх окая, даже задами из хватілю логан', 
    time: '17:26', 
    isOutgoing: true,
    isRead: true 
  },
  { 
    id: 18, 
    text: 'Все, знакомый звѣд...', 
    time: '17:40', 
    isOutgoing: false 
  },
  { 
    id: 19, 
    text: 'Убже убатли, чи на один віч...', 
    time: '17:40', 
    isOutgoing: false 
  },
  { 
    id: 20, 
    text: 'Такіш бігщвт на малва віє', 
    time: '17:40', 
    isOutgoing: false 
  },
];

export function ChatWindow({ chat }: ChatWindowProps) {
  const [messageText, setMessageText] = useState('');

  const handleSendMessage = () => {
    if (messageText.trim()) {
      // В реальном приложении здесь будет логика отправки
      setMessageText('');
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  return (
    <div className="flex-1 flex flex-col bg-gradient-to-b from-[#C6DBED] to-[#C9E2F1]">
      {/* Chat Header */}
      <div className="bg-white border-b border-gray-200 px-4 py-2 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="relative">
            <img
              src={chat.avatar}
              alt={chat.name}
              className="w-10 h-10 rounded-full object-cover"
            />
            {chat.online && (
              <div className="absolute bottom-0 right-0 w-3 h-3 bg-[#0088cc] rounded-full border-2 border-white"></div>
            )}
          </div>
          <div>
            <h2 className="font-medium text-[15px] text-gray-900">{chat.name}</h2>
            <p className="text-xs text-gray-500">
              {chat.online ? 'в сети' : 'был(а) недавно'}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-4">
          <button className="text-gray-500 hover:text-gray-700 transition-colors">
            <Search size={20} />
          </button>
          <button className="text-gray-500 hover:text-gray-700 transition-colors">
            <Phone size={20} />
          </button>
          <button className="text-gray-500 hover:text-gray-700 transition-colors">
            <MoreVertical size={20} />
          </button>
        </div>
      </div>

      {/* Messages Area */}
      <div className="flex-1 overflow-y-auto p-4">
        <div className="max-w-4xl mx-auto">
          {mockMessages.map((message) => (
            <Message
              key={message.id}
              text={message.text}
              time={message.time}
              isOutgoing={message.isOutgoing}
              isRead={message.isRead}
              avatar={!message.isOutgoing ? chat.avatar : undefined}
              senderName={!message.isOutgoing ? chat.name : undefined}
            />
          ))}
        </div>
      </div>

      {/* Input Area */}
      <div className="bg-white border-t border-gray-200 px-4 py-3">
        <div className="max-w-4xl mx-auto flex items-end gap-2">
          <button className="text-gray-500 hover:text-gray-700 transition-colors pb-2">
            <Paperclip size={22} />
          </button>
          
          <div className="flex-1 bg-white rounded-xl border border-gray-300 flex items-end">
            <textarea
              value={messageText}
              onChange={(e) => setMessageText(e.target.value)}
              onKeyDown={handleKeyPress}
              placeholder="Написать сообщение..."
              className="flex-1 px-4 py-2 outline-none resize-none max-h-32 bg-transparent"
              rows={1}
            />
            <button className="text-gray-500 hover:text-gray-700 transition-colors p-2">
              <Smile size={22} />
            </button>
          </div>

          <button className="text-gray-500 hover:text-gray-700 transition-colors pb-2">
            <Mic size={22} />
          </button>
        </div>
      </div>
    </div>
  );
}
