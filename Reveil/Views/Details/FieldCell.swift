//
//  FieldCell.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

private struct FieldCell_Internal: View {
    let label: String
    let description: String
    let color: Color?
    let delegate: FieldCellDelegate?
    let isPinnable: Bool

    @AppCodableStorage<Pin> var pin: Pin {
        didSet {
            delegate?.showToast(
                message: String(format: pin.isPinned ? NSLocalizedString("PINNED_FMT", comment: "Pinned %@") : NSLocalizedString("UNPINNED_FMT", comment: "Unpinned %@"), label),
                icon: pin.isPinned ? "pin.fill" : "pin",
                dismissInterval: 3.0
            )
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            HStack {
                if let color {
                    Image(systemName: "circle.fill")
                        .font(Font.system(.caption2))
                        .foregroundColor(color)
                }

                Text(label)
                    .font(Font.system(.body))

                if #available(iOS 15.0, *), isPinnable {
                    Menu {
                        if pin.isPinned {
                            Button {
                                pin = Pin(false)
                            } label: {
                                Label(NSLocalizedString("UNPIN", comment: "Unpin"), systemImage: "pin")
                            }
                        } else {
                            Button {
                                pin = Pin(true)
                            } label: {
                                Label(NSLocalizedString("PIN", comment: "Pin"), systemImage: "pin.fill")
                            }
                        }
                    } label: {
                        Image(systemName: pin.isPinned ? "pin.fill" : "pin")
                            .font(Font.system(.footnote))
                            .foregroundColor(Color(PlatformColor.secondaryLabelAlias))
                            .rotationEffect(.degrees(45))
                    } primaryAction: {
                        pin = Pin(negate: pin)
                    }
                } else {
                    // Fallback on earlier versions
                }
            }

            Spacer()

            Text(description)
                .font(.system(.body).monospacedDigit())
                .foregroundColor(Color(PlatformColor.secondaryLabelAlias))
                .multilineTextAlignment(.trailing)
        }
    }
}

struct FieldCell: View {
    @StateObject var entry: BasicEntry
    let delegate: FieldCellDelegate?

    var body: some View {
        FieldCell_Internal(
            label: entry.name,
            description: entry.value,
            color: entry.color,
            delegate: delegate,
            isPinnable: entry.key.isPinnable,
            pin: entry.key.isPinnable ? AppCodableStorage(
                wrappedValue: Pin(false), entry.key,
                store: PinStorage.shared.userDefaults
            ) : AppCodableStorage(wrappedValue: Pin(false), .Custom(name: String()))
        )
    }
}

// MARK: - Previews

struct FieldCell_Previews: PreviewProvider {
    static var previews: some View {
        FieldCell(entry: BasicEntry(
            key: .HostName,
            name: "Host Name",
            value: "ZMini"
        ), delegate: nil).padding()

        FieldCell(entry: BasicEntry(
            key: .CPUUsageUser,
            name: "User",
            value: "10.68%",
            color: Color.accentColor
        ), delegate: nil).padding()

        FieldCell(entry: BasicEntry(
            key: .KernelVersion,
            name: "Kernel Version",
            value: "Darwin Kernel Version 21.4.0: Mon Feb 21 21:27:55 PST 2022; root:xnu-8020.102.3~1/RELEASE_ARM64_T8101"
        ), delegate: nil).padding()

        FieldCell(entry: BasicEntry(
            key: .MemoryBytesWired,
            name: "Wired",
            value: "689.50 MB\n17.88%",
            color: Color("MemoryWired")
        ), delegate: nil).padding()
    }
}
