import SwiftUI

struct ChatView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var messageText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.chatMessages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if viewModel.isTyping {
                                TypingIndicator()
                                    .id("typingIndicator")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.chatMessages.count) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: viewModel.isTyping) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                }
                
                HStack(spacing: 12) {
                    TextField("Ask your coach...", text: $messageText)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(20)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
            .navigationTitle("AI Assistant")
        }
    }
    
    private func sendMessage() {
        viewModel.sendChatMessage(messageText)
        messageText = ""
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation {
            if viewModel.isTyping {
                proxy.scrollTo("typingIndicator", anchor: .bottom)
            } else {
                proxy.scrollTo(viewModel.chatMessages.last?.id, anchor: .bottom)
            }
        }
    }
}

struct TypingIndicator: View {
    @State private var dotOffset: CGFloat = 0
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(.secondary)
                        .offset(y: i == 0 ? dotOffset : (i == 1 ? dotOffset * 0.8 : dotOffset * 0.6))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(18)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    dotOffset = -6
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.sender == .user { Spacer() }
            
            Text(message.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(message.sender == .user ? Color.blue : Color(UIColor.secondarySystemBackground))
                .foregroundColor(message.sender == .user ? .white : .primary)
                .cornerRadius(18)
                .shadow(radius: 1)
            
            if message.sender == .ai { Spacer() }
        }
    }
}
