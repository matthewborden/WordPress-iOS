import Foundation
import WordPressShared


extension WPStyleGuide {
    // MARK: - Styles Used by the WordPress Share Extension
    //
    class Share {
        static let blavatarPlaceholderImage = UIImage(named: "blavatar-default")

        static func configureModuleCell(_ cell: UITableViewCell) {
            cell.textLabel?.font = tableviewTextFont()
            cell.textLabel?.sizeToFit()
            cell.textLabel?.textColor = darkGrey()

            cell.detailTextLabel?.font = tableviewSubtitleFont()
            cell.detailTextLabel?.sizeToFit()
            cell.detailTextLabel?.textColor = grey()

            cell.backgroundColor = UIColor.white
            cell.separatorInset = UIEdgeInsets.zero
        }

        static func configureCategoryCell(_ cell: UITableViewCell) {
            cell.textLabel?.font = tableviewTextFont()
            cell.textLabel?.sizeToFit()
            cell.textLabel?.textColor = darkGrey()
            cell.textLabel?.numberOfLines = 0

            cell.backgroundColor = UIColor.white
            cell.separatorInset = UIEdgeInsets.zero
            cell.tintColor = wordPressBlue()
        }

        static func configureTagCell(_ cell: UITableViewCell) {
            cell.textLabel?.font = tableviewTextFont()
            cell.textLabel?.sizeToFit()
            cell.textLabel?.textColor = darkGrey()

            cell.backgroundColor = UIColor.white
            cell.separatorInset = UIEdgeInsets.zero
        }

        static func configureLoadingTagCell(_ cell: UITableViewCell) {
            cell.textLabel?.font = tableviewTextFont()
            cell.textLabel?.sizeToFit()
            cell.textLabel?.textColor = darkGrey()

            cell.backgroundColor = .neutral(shade: .shade50)
            cell.separatorInset = UIEdgeInsets.zero
        }

        static func configureTableViewSummaryCell(_ cell: UITableViewCell) {
            cell.textLabel?.font = tableviewTextFont()
            cell.textLabel?.sizeToFit()
            cell.textLabel?.textColor = darkGrey()

            cell.backgroundColor = UIColor.clear
            cell.separatorInset = UIEdgeInsets.zero
        }

        static func configureTableViewSiteCell(_ cell: UITableViewCell) {
            cell.textLabel?.font = tableviewTextFont()
            cell.textLabel?.sizeToFit()
            cell.textLabel?.textColor = darkGrey()
            cell.textLabel?.numberOfLines = 0

            cell.detailTextLabel?.font = subtitleFont()
            cell.detailTextLabel?.sizeToFit()
            cell.detailTextLabel?.textColor = greyDarken10()
            cell.detailTextLabel?.numberOfLines = 0

            cell.imageView?.layer.borderColor = UIColor.white.cgColor
            cell.imageView?.layer.borderWidth = 1
            cell.imageView?.tintColor = greyLighten10()

            cell.backgroundColor = UIColor.white
            cell.tintColor = wordPressBlue()
        }
    }
}
