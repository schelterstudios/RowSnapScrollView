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
