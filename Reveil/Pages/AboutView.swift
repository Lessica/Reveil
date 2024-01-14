//
//  AboutView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/2.
//

import QuickLook
import SwiftUI

private let gDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .none
    formatter.dateStyle = .short
    return formatter
}()

private let gBuildDateString: String? = {
    guard let executableURL = Bundle.main.executableURL,
          let creationDate = (try? executableURL.resourceValues(forKeys: [.creationDateKey]))?.creationDate
    else {
        return nil
    }
    return gDateFormatter.string(from: creationDate)
}()

private let gVersionString: String? = {
    guard let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
          let buildVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    else {
        return nil
    }
    return String(
        format: "%@ (%@)",
        versionString,
        buildVersionString
    )
}()

struct AboutView: View {
    @State var quickLookExport: URL?

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .center, spacing: 20) {
                Image("IconShape")
                    .resizable()
                    .foregroundColor(colorScheme == .light ? .accent : .white)
                    .frame(width: 128, height: 128)

                Text("Good artists copy, great artists steal.")
                    .font(.system(.footnote))
                    .bold()
                    .foregroundColor(colorScheme == .light ? .accent : .white)
                    .padding(.bottom, 32)

                Section {
                    Link(destination: URL(string: "https://github.com/Lessica/Reveil")!) {
                        LinkCell(
                            label: NSLocalizedString("WEBSITE", comment: "Website"),
                            iconName: "github-mark-white",
                            hasClosure: true
                        )
                    }

                    Link(destination: URL(string: "https://github.com/Lessica")!) {
                        LinkCell(
                            label: NSLocalizedString("DEVELOPER", comment: "Developer"),
                            description: "@Lessica",
                            hasClosure: true
                        )
                    }

                    Link(destination: URL(string: "https://twitter.com/Lakr233")!) {
                        LinkCell(
                            label: NSLocalizedString("DEVELOPER", comment: "Developer"),
                            description: "@Lakr233",
                            hasClosure: true
                        )
                    }

                    Link(destination: URL(string: "mailto:82flex@gmail.com")!) {
                        LinkCell(
                            label: NSLocalizedString("CONTACT", comment: "Contact"),
                            description: NSLocalizedString("CONTACT_EMAIL", comment: "82flex@gmail.com"),
                            hasClosure: true
                        )
                    }

                    LinkCell(
                        label: NSLocalizedString("VERSION", comment: "Version"),
                        description: gVersionString
                    )

                    LinkCell(
                        label: NSLocalizedString("BUILD_DATE", comment: "Build Date"),
                        description: gBuildDateString
                    )
                } footer: {
                    Text(NSLocalizedString("COPYRIGHT_STRING", comment: "Copyright © 2023-2024 Lessica & Lakr Aream.\nAll rights reserved."))
                        .font(Font.system(.footnote))
                        .foregroundColor(Color(PlatformColor.secondaryLabelAlias))
                        .multilineTextAlignment(.center)
                        .padding()
                }

                Button(NSLocalizedString("SEND_DIAGNOSTIC_DATA", comment: "Send Diagnostic Data")) {
                    let data = exportPropertyListData()
                    let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory())
                        .appendingPathComponent("ReveilExport_" + UUID().uuidString)
                        .appendingPathExtension("plist")
                    try? data.write(to: tempUrl, options: .atomic)
                    quickLookExport = tempUrl
                }
                .foregroundStyle(accent: true)
                .quickLookPreview($quickLookExport)
            }
            .padding()
        }
    }
}

// MARK: - Previews

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

// MARK: - EXPORTER

extension AboutView {
    func exportPropertyListData() -> Data {
        var entryExporters = Array(arrayLiteral: EntryExporter(provider: Security.shared))

        entryExporters.append(contentsOf: Dashboard.shared
            .registeredModules
            .map { EntryExporter(module: $0) })

        let moduleMappings = entryExporters.reduce(into: [String: EntryExporter]()) {
            $0[$1.moduleClass] = $1
        }

        do {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            let propertyListData = try encoder.encode(moduleMappings)
            return propertyListData
        } catch {
            assertionFailure(error.localizedDescription)
            return .init()
        }
    }
}

private struct LinkCell: View {
    let label: String
    var iconName: String? = nil
    var description: String? = nil
    var hasClosure: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(Font.system(.body))
                .foregroundColor(.primary)
                .lineLimit(1)

            Spacer()

            if let iconName {
                Image(iconName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFill()
                    .foregroundColor(Color(PlatformColor.secondaryLabelAlias))
                    .frame(width: 18, height: 18)
            }

            if let description {
                Text(description)
                    .font(Font.system(.body))
                    .foregroundColor(Color(PlatformColor.secondaryLabelAlias))
                    .lineLimit(1)
            }

            if hasClosure {
                Spacer().frame(width: 12)

                Image(systemName: "chevron.right")
                    .font(Font.system(.body).weight(.bold))
                    .foregroundColor(Color(PlatformColor.tertiaryLabelAlias))
            }
        }
    }
}
