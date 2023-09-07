import SwiftUI


func ZText(_ content: String, size: Double = 17.0) -> Text {
    return Text(content).font(.custom("Neue Haas Unica Pro", size: size))
}

struct ZButton: View {

    let title: String
    let action: () -> Void

    var body: some View {

        Button(action: action,
               label: {
                ZText(title.uppercased())
                    .fontWeight(.medium)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
               }
        )
        .background(Color.purple5)
        .frame(maxHeight: 56)
        .cornerRadius(2)
    }
}

struct TopBarButton<Label>: View where Label: View {

    let action: () -> Void
    let label: () -> Label
    
    var body: some View {
        Button(action: action, label: label)
            .frame(width: 58, height: 64)
    }
}

struct BottomBarButton<Label>: View where Label: View {

    let action: () -> Void
    let label: () -> Label
    let color: Color
    
    init(action: @escaping () -> Void, label: @escaping () -> Label, color: Color = .grey1) {
        self.action = action
        self.label = label
        self.color = color
    }
    
    var body: some View {
        Button(action: action, label: label)
            .padding(16)
            .background(
                Circle().fill(color)
            )
            .frame(width: 56, height: 56)
    }
}

let fontFileNames = [
    "zocksiconfont",
    "NeueHaasUnicaPro-Black",
    "NeueHaasUnicaPro-BlackIt",
    "NeueHaasUnicaPro-Bold",
    "NeueHaasUnicaPro-BoldItalic",
    "NeueHaasUnicaPro-Heavy",
    "NeueHaasUnicaPro-HeavyIt",
    "NeueHaasUnicaPro-Italic",
    "NeueHaasUnicaPro-Light",
    "NeueHaasUnicaPro-LightIt",
    "NeueHaasUnicaPro-Medium",
    "NeueHaasUnicaPro-MediumIt",
    "NeueHaasUnicaPro-Regular",
    "NeueHaasUnicaPro-Thin",
    "NeueHaasUnicaPro-ThinItalic",
    "NeueHaasUnicaPro-UltLightIt",
    "NeueHaasUnicaPro-UltraLight",
    "NeueHaasUnicaPro-XBlack",
    "NeueHaasUnicaPro-XBlackIt"
]

public struct Zocks {
    
    public static func registerFonts() {
        fontFileNames.forEach {
            registerFont(bundle: .module, fontName: $0, fontExtension: "ttf")
        }
    }
    
    fileprivate static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) {

        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension),
              let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider) else {
                  fatalError("Couldn't create font from data")
        }

        var error: Unmanaged<CFError>?

        CTFontManagerRegisterGraphicsFont(font, &error)
    }
    
}

struct ConfirmDialog: ViewModifier {
    
    @Binding var isShowing: Bool
    let action: () -> Void
    
    init(isShowing: Binding<Bool>,
         action: @escaping () -> Void) {
        _isShowing = isShowing
        self.action = action
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing {
                Rectangle().foregroundColor(Color.black.opacity(0.6))
                ZStack {
                    VStack(spacing: 0) {
                        HStack {
                            ZText("Leave meeting")
                                .fontWeight(.medium)
                                .padding(.leading, 24)
                            Spacer()
                            Button(action: {
                                isShowing = false
                            }) {
                                Icon(icon: .close)
                                    
                            }.padding(.trailing, 16)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 65)
                        .background(Color.grey3)
                        HStack {
                            ZText("Please, confirm that you would like to leave the meeting", size: 14.0)
                                .multilineTextAlignment(.leading)
                                .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        HStack {
                            Spacer()
                            Button(action: {
                                isShowing = false
                            }) {
                                ZText("BACK")
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .padding()
                            }.frame(maxHeight: 56)
                            ZButton(title: "LEAVE") {
                                isShowing = false
                                action()
                            }
                            .frame(minWidth: 151)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 0, leading: 24, bottom: 24, trailing: 24))
                    }
                    .background(
                                  RoundedRectangle(cornerRadius: 4)
                                    .foregroundColor(Color.grey2))
                }.frame(width: 327, height: 233)
            }
        }
    }
}
