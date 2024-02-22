import UIKit
import DesignSystem

final class NotificationsTableHeaderView: UITableViewHeaderFooterView {

    static let reuseIdentifier: String = String(describing: NotificationsTableHeaderView.self)

    // MARK: - Properties

    var text: String? {
        didSet {
            self.update(text: text)
        }
    }

    var style: Style = .leading {
        didSet {
            self.update(style: style)
        }
    }

    // MARK: - Init

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        self.contentConfiguration = {
            var config = super.defaultContentConfiguration()
            config.textProperties.font = Appearance.textFont
            config.textProperties.color = Appearance.textColor
            config.directionalLayoutMargins = Appearance.layoutMarginsLeading
            return config
        }()
        if #available(iOS 16.0, *) {
            self.backgroundConfiguration = {
                var config = self.defaultBackgroundConfiguration()
                config.backgroundColor = Appearance.backgroundColor
                config.visualEffect = nil
                return config
            }()
        } else {
            self.contentView.backgroundColor = Appearance.backgroundColor
        }
    }

    // MARK: - Update

    private func update(text: String?) {
        guard var config = contentConfiguration as? UIListContentConfiguration else {
            return
        }
        config.text = text
        self.contentConfiguration = config
    }

    private func update(style: Style) {
        if var config = self.contentConfiguration as? UIListContentConfiguration {
            switch style {
            case .leading:
                config.directionalLayoutMargins = Appearance.layoutMarginsLeading
            case .subsequent:
                config.directionalLayoutMargins = Appearance.layoutMarginsSubsequent
            }
            self.contentConfiguration = config
        }
    }

    // MARK: - Constants

    private enum Appearance {
        static let backgroundColor = UIColor.systemBackground
        static let textColor = UIColor.DS.Foreground.primary ?? .text
        static let textFont = UIFont.DS.font(.bodyLarge(.emphasized))
        static let layoutMarginsLeading = NSDirectionalEdgeInsets(
            top: Length.Padding.double,
            leading: Length.Padding.double,
            bottom: Length.Padding.half,
            trailing: Length.Padding.double
        )
        static let layoutMarginsSubsequent = NSDirectionalEdgeInsets(
            top: Length.Padding.double + Length.Padding.split,
            leading: Length.Padding.double,
            bottom: Length.Padding.half,
            trailing: Length.Padding.double
        )
    }

    enum Style {
        case leading
        case subsequent
    }

}
