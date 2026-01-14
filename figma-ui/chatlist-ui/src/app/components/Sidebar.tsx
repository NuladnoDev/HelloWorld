import { Menu, Settings, Moon, Archive, MessageSquare, Users, Phone, Bookmark } from 'lucide-react';

export function Sidebar() {
  return (
    <div className="w-14 bg-[#2B5278] flex flex-col items-center py-4 gap-6">
      <button className="text-white/90 hover:text-white transition-colors">
        <Menu size={24} />
      </button>
      
      <div className="flex-1 flex flex-col gap-6 mt-4">
        <button className="text-white/90 hover:text-white transition-colors">
          <MessageSquare size={22} />
        </button>
        <button className="text-white/60 hover:text-white transition-colors">
          <Users size={22} />
        </button>
        <button className="text-white/60 hover:text-white transition-colors">
          <Phone size={22} />
        </button>
        <button className="text-white/60 hover:text-white transition-colors">
          <Bookmark size={22} />
        </button>
        <button className="text-white/60 hover:text-white transition-colors">
          <Archive size={22} />
        </button>
      </div>
      
      <div className="flex flex-col gap-6">
        <button className="text-white/60 hover:text-white transition-colors">
          <Moon size={22} />
        </button>
        <button className="text-white/60 hover:text-white transition-colors">
          <Settings size={22} />
        </button>
      </div>
    </div>
  );
}
