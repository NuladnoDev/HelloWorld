import { useState } from 'react';
import { Sidebar } from './components/Sidebar';
import { ChatList } from './components/ChatList';
import { ChatWindow } from './components/ChatWindow';

interface Chat {
  id: number;
  name: string;
  lastMessage: string;
  time: string;
  avatar: string;
  unread?: number;
  online?: boolean;
}

export default function App() {
  const [selectedChat, setSelectedChat] = useState<Chat | null>(null);

  return (
    <div className="h-screen flex overflow-hidden bg-gray-100">
      <Sidebar />
      <ChatList 
        onSelectChat={setSelectedChat} 
        selectedChatId={selectedChat?.id}
      />
      {selectedChat ? (
        <ChatWindow chat={selectedChat} />
      ) : (
        <div className="flex-1 flex items-center justify-center bg-gradient-to-b from-[#C6DBED] to-[#C9E2F1]">
          <div className="text-center text-gray-500">
            <p className="text-lg">Выберите чат для начала общения</p>
          </div>
        </div>
      )}
    </div>
  );
}
