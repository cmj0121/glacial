import receive_sharing_intent

class ShareViewController: RSIShareViewController {

    // Automatically redirect to host app after sharing.
    override func shouldAutoRedirect() -> Bool {
        return true
    }
}
