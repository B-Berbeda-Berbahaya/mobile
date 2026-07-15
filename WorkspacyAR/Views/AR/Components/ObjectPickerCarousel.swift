import SwiftUI

struct ObjectPickerCarousel: View {
    @Binding var selectedObjectType: PlaceableObjectType
    @Binding var selectedCategory: ItemCategory
    
    var body: some View {
        VStack(spacing: 12) {
            // Category selector tabs
            HStack(spacing: 20) {
                ForEach(ItemCategory.allCases) { category in
                    Button(action: {
                        selectedCategory = category
                        // Auto-select first item in new category
                        if let firstInCat = PlaceableObjectType.allCases.first(where: { $0.category == category }) {
                            selectedObjectType = firstInCat
                        }
                    }) {
                        Text(category.rawValue)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(selectedCategory == category ? .primary : .secondary)
                            .padding(.bottom, 4)
                            .overlay(
                                Rectangle()
                                    .fill(selectedCategory == category ? Color.accentColor : Color.clear)
                                    .frame(height: 2)
                                    .offset(y: 4),
                                alignment: .bottom
                            )
                    }
                }
            }
            .padding(.top, 8)
            
            // Items list carousel
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PlaceableObjectType.allCases.filter { $0.category == selectedCategory }) { type in
                        Button(action: {
                            selectedObjectType = type
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedObjectType == type ? Color.accentColor.opacity(0.12) : Color(.tertiarySystemGroupedBackground))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: type.sfSymbol)
                                        .font(.title3)
                                        .foregroundColor(selectedObjectType == type ? Color.accentColor : .secondary)
                                }
                                
                                Text(type.displayName)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .frame(width: 75)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                            .background(selectedObjectType == type ? Color(.secondarySystemGroupedBackground) : Color.clear)
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground).opacity(0.95))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: -2)
    }
}

#Preview {
    ObjectPickerCarousel(
        selectedObjectType: .constant(.ergonomicChair),
        selectedCategory: .constant(.furniture)
    )
}
