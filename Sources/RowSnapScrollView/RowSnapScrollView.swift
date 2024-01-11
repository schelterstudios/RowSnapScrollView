// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct RowSnapScrollView<
    Data: RandomAccessCollection, Content: View
>: View where Data.Element: Identifiable & Equatable {
    
    let data: Data
    @Binding var snappedItem: Data.Element?
    let spacing: CGFloat
    let padding: CGFloat
    
    private let height: (Data.Element) -> CGFloat
    @ViewBuilder private let content: (Data.Element) -> Content
    @State private var scrollPosition: Data.Element.ID?
    
    public init(_ data: Data,
         snappedItem: Binding<Data.Element?>,
         spacing: CGFloat = 10, padding: CGFloat = 10,
         height: @escaping (Data.Element) -> CGFloat,
         @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self._snappedItem = snappedItem
        self.spacing = spacing
        self.padding = padding
        self.height = height
        self.content = content
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: spacing) {
                ForEach(data) { item in
                    content(item).id(item.id)
                }
            }
            .padding(padding)
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrollPosition)
        .scrollTargetBehavior(
            RowSnapScrollTargetBehavior<Data>(
                data: data,
                spacing: spacing,
                height: height
            )
        )
        .onChange(of: scrollPosition, initial: false) { _, scrollID in
            snappedItem = data.last { $0.id == scrollID }
        }
        .onChange(of: snappedItem, initial: true) { prev, item in
            guard prev != item else { return }
            let update = { scrollPosition = snappedItem?.id }
            if prev != nil { withAnimation(.default, update) }
            else { update() }
        }
    }
}

private struct RowSnapScrollTargetBehavior<
    Data: RandomAccessCollection
>: ScrollTargetBehavior {
    
    private let snapPoints: [CGFloat]
    
    init(data: Data,
         spacing: CGFloat,
         height: (Data.Element) -> CGFloat
    ) {
        var snapPoints: [CGFloat] = []
        var y: CGFloat = 0
        for element in data {
            snapPoints.append(y)
            y += height(element) + spacing
        }
        self.snapPoints = snapPoints
    }
    
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        let lower = snapPoints.last{ $0 <= target.rect.minY }
        let higher = snapPoints.first{ $0 > target.rect.minY }
        
        if let lower, let higher {
            if target.rect.origin.y - lower < higher - target.rect.origin.y {
                target.rect.origin.y = lower
            } else {
                target.rect.origin.y = higher
            }
            
        } else if let lower {
            target.rect.origin.y = lower
            
        } else if let higher {
            target.rect.origin.y = higher
        }
    }
}

#if DEBUG
private struct RowSnapScrollViewPreviewer: View {
    
    struct Message: Equatable, Identifiable {
        enum MessageType {
            case sent, received
        }
        let id = UUID()
        let type: MessageType
        let text: String
    }
    
    let data: [Message] = [
        .init(type: .received, text: "Hello, How may I help you today?"),
        .init(type: .received, text: "..."),
        .init(type: .received, text: "Hello, World?"),
        .init(type: .sent, text: "Yes, hi, I am trying to test a snapping row scroll view."),
        .init(type: .sent, text: "It needs to snap to the top-most visible row, and support variable row heights."),
        .init(type: .received, text: "Well you're in luck! This component does just that!"),
        .init(type: .received, text: "Additionally, snappedItem is a binding that allows you to programmatically scroll your view to the top of the specified item."),
        .init(type: .sent, text: "Oh nice! 👍"),
    ]
    
    @State private var snappedItem: Message?
    
    var body: some View {
        RowSnapScrollView(
            data, snappedItem: $snappedItem
        ) { item in
            let size = item.text.boundingRect(
                with: .init(width: 330.0 - (16*2), height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [.font: UIFont.preferredFont(forTextStyle: .title1)],
                context: nil
            )
            return size.height + (16*2)
            
        } content: { item in
            HStack(spacing:0) {
                if item.type == .sent { Spacer() }
                
                Text(item.text)
                    .font(.title)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: item == snappedItem ? 4 : 0)
                            .fill(item.type == .sent ? Color.cyan : Color.yellow)
                    )
                    .onTapGesture{
                        snappedItem = item
                    }
                
                if item.type == .received { Spacer() }
            }
            .frame(width: 330)
        }
    }
}

#Preview {
    RowSnapScrollViewPreviewer()
}
#endif
