import Foundation
import WordPressShared.WPTableViewCell

open class CommentsTableViewCell: WPTableViewCell {

    // MARK: - IBOutlets

    @IBOutlet private weak var pendingIndicator: UIView!
    @IBOutlet private weak var pendingIndicatorWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var gravatarImageView: CircularImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var timestampImageView: UIImageView!
    @IBOutlet private weak var timestampLabel: UILabel!

    // MARK: - Private Properties

    private var author = String()
    private var postTitle = String()
    private var content = String()
    private var timestamp: String?
    private var approved: Bool = false
    private var gravatarURL: URL?
    private typealias Style = WPStyleGuide.Comments
    private let placeholderImage = Style.gravatarPlaceholderImage

    private enum Labels {
        static let noTitle = NSLocalizedString("(No Title)", comment: "Empty Post Title")
        static let titleFormat = NSLocalizedString("%1$@ on %2$@", comment: "Label displaying the author and post title for a Comment. %1$@ is a placeholder for the author. %2$@ is a placeholder for the post title.")
    }

    // MARK: - Public Properties

    @objc static let reuseIdentifier = "CommentsTableViewCell"

    // MARK: - Public Methods

    @objc func configureWithComment(_ comment: Comment) {
        author = comment.authorForDisplay() ?? String()
        approved = (comment.status == CommentStatusApproved)
        postTitle = comment.titleForDisplay() ?? Labels.noTitle
        content = comment.contentPreviewForDisplay() ?? String()
        timestamp = comment.dateCreated.mediumString()

        if let avatarURLForDisplay = comment.avatarURLForDisplay() {
            downloadGravatarWithURL(avatarURLForDisplay)
        } else {
            downloadGravatarWithGravatarEmail(comment.gravatarEmailForDisplay())
        }

        backgroundColor = Style.backgroundColor
        configurePendingIndicator()
        configureCommentLabels()
        configureTimestamp()
    }

}

private extension CommentsTableViewCell {

    // MARK: - Gravatar Downloading

    func downloadGravatarWithURL(_ url: URL?) {
        if url == gravatarURL {
            return
        }

        let gravatar = url.flatMap { Gravatar($0) }
        gravatarImageView.downloadGravatar(gravatar, placeholder: placeholderImage, animate: true)

        gravatarURL = url
    }

    func downloadGravatarWithGravatarEmail(_ email: String?) {
        guard let unwrappedEmail = email else {
            gravatarImageView.image = placeholderImage
            return
        }

        gravatarImageView.downloadGravatarWithEmail(unwrappedEmail, placeholderImage: placeholderImage)
    }

    // MARK: - Configure UI

    func configurePendingIndicator() {
        pendingIndicator.layer.cornerRadius = pendingIndicatorWidthConstraint.constant / 2
        pendingIndicator.backgroundColor = approved ? .clear : Style.pendingIndicatorColor
    }

    func configureCommentLabels() {
        titleLabel.attributedText = attributedTitle()
        detailLabel.text = content
        detailLabel.font = Style.detailFont
        detailLabel.textColor = Style.detailTextColor
    }

    func configureTimestamp() {
        timestampLabel.text = timestamp
        timestampLabel.font = Style.timestampFont
        timestampLabel.textColor = Style.detailTextColor
        timestampImageView.image = Style.timestampImage

    }

    func attributedTitle() -> NSAttributedString {
        let replacementMap = [
            "%1$@": NSAttributedString(string: author, attributes: Style.titleBoldAttributes),
            "%2$@": NSAttributedString(string: postTitle, attributes: Style.titleBoldAttributes)
        ]

        // Replace Author + Title
        let attributedTitle = NSMutableAttributedString(string: Labels.titleFormat, attributes: Style.titleRegularAttributes)

        for (key, attributedString) in replacementMap {
            let range = (attributedTitle.string as NSString).range(of: key)
            if range.location != NSNotFound {
                attributedTitle.replaceCharacters(in: range, with: attributedString)
            }
        }

        return attributedTitle
    }

}
