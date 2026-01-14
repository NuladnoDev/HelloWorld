import { Check, CheckCheck } from 'lucide-react';

interface MessageProps {
  text: string;
  time: string;
  isOutgoing: boolean;
  isRead?: boolean;
  avatar?: string;
  senderName?: string;
}

export function Message({ text, time, isOutgoing, isRead = false, avatar, senderName }: MessageProps) {
  return (
    <div className={`flex gap-2 mb-2 ${isOutgoing ? 'justify-end' : 'justify-start'}`}>
      {!isOutgoing && avatar && (
        <img
          src={avatar}
          alt={senderName}
          className="w-8 h-8 rounded-full object-cover flex-shrink-0 mt-1"
        />
      )}
      
      <div
        className={`max-w-[500px] px-3 py-2 rounded-2xl ${
          isOutgoing
            ? 'bg-[#EFFDDE] rounded-br-sm'
            : 'bg-white rounded-bl-sm shadow-sm'
        }`}
      >
        {!isOutgoing && senderName && (
          <div className="text-[13px] font-medium text-[#0088cc] mb-1">
            {senderName}
          </div>
        )}
        
        <div className="text-[15px] text-gray-900 leading-relaxed break-words">
          {text}
        </div>
        
        <div className={`flex items-center gap-1 justify-end mt-1 ${
          isOutgoing ? 'text-[#4FAE4E]' : 'text-gray-500'
        }`}>
          <span className="text-[11px]">{time}</span>
          {isOutgoing && (
            <span>
              {isRead ? (
                <CheckCheck size={14} />
              ) : (
                <Check size={14} />
              )}
            </span>
          )}
        </div>
      </div>
    </div>
  );
}
