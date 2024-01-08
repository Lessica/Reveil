//
//  CheckmarkWidget.swift
//  Reveil
//
//  Created by Lessica on 2023/10/3.
//

import ColorfulX
import SwiftUI
import SwiftUIBackports

struct CheckmarkWidget: View {
    @StateObject var securityModel: Security = .shared
    @State var openDetail: Bool = false

    var isAnimatedBackgroundEnabled: Bool {
        StandardUserDefaults.shared.isAnimatedBackgroundEnabled && !ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    var isLowFrameRateEnabled: Bool = StandardUserDefaults.shared.isLowFrameRateEnabled
    var isLegacyUIEnabled: Bool = StandardUserDefaults.shared.isLegacyUIEnabled

    var usesLegacyStyle: Bool {
        isLegacyUIEnabled || !isAnimatedBackgroundEnabled
    }

    var label: String { securityModel.description }
    var isLoading: Bool { securityModel.isLoading }
    var isInsecure: Bool { securityModel.isInsecure }
    var description: String {
        (
            securityModel.isLoading
                ? NSLocalizedString("SCANNING", comment: "Scanning…")
                : (securityModel.isInsecure ?
                    NSLocalizedString("MODIFICATIONS_FOUND", comment: "Modifications found")
                    : NSLocalizedString("NO_ISSUES_FOUND", comment: "No issues found")
                )
        ).capitalized
    }

    var labelColor: Color {
        if usesLegacyStyle {
            return isInsecure ? .white : .primary
        }
        return .white
    }

    var descriptionColor: Color {
        if usesLegacyStyle {
            return isInsecure ? .white : .accent
        }
        return .white
    }

    var backgroundColor: Color {
        if isInsecure { return Color("SecurityLeaks") }
        return Color(PlatformColor.secondarySystemBackgroundAlias)
    }

    var animatedBackgroundColors: [Color] {
        if isLoading { return ColorfulPreset.aurora.colors }
        if isInsecure { return [.red, .pink, .red, .pink] }
        return [.accent, .accent, .accent, .accent]
    }

    var colorfulBackground: some View {
        ColorfulView(
            color: .init(get: { animatedBackgroundColors }, set: { _ in }),
            speed: isAnimatedBackgroundEnabled ? .constant(0.5) : .constant(0),
            transitionInterval: isAnimatedBackgroundEnabled ? .constant(1) : .constant(0),
            frameLimit: isLowFrameRateEnabled ? 30 : 60
        )
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(label.uppercased())
                    .font(Font.system(.body))
                    .fontWeight(.bold)
                    .lineLimit(1)
                Spacer()
                if !isLoading, isInsecure {
                    Image(systemName: "chevron.right")
                        .font(Font.system(.body).weight(.regular))
                }
            }
            .foregroundColor(labelColor)

            HStack {
                Image(systemName: isLoading ? "magnifyingglass.circle.fill" : (isInsecure ? "xmark.circle.fill" : "checkmark.circle.fill"))
                    .font(Font.system(.title).weight(.medium))
                Text(description)
                    .font(Font.system(.title).weight(.medium))
                    .lineLimit(1)
                Spacer()
            }
            .foregroundColor(descriptionColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.all, 12)
        .backport.background {
            if usesLegacyStyle {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(backgroundColor)
                    .opacity(isInsecure ? 0.75 : 0.25)
            } else {
                self.colorfulBackground
                    .opacity(0.75)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .backport.overlay {
            if usesLegacyStyle && !isInsecure {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(PlatformColor.separatorAlias), lineWidth: 1)
                    .opacity(isInsecure ? 0 : 1)
            }
        }
        .onChange(of: isLoading) { _ in
            if isLoading { openDetail = false }
        }
        .background(
            NavigationLink(
                "",
                destination: SecurityView().environmentObject(HighlightedEntryKey()),
                isActive: $openDetail
            )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if isLoading { return }
            openDetail = true
        }
    }
}
