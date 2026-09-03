/// Configuration class for iOS & MacOS platform.
final class AppleConfig {
  /// Required when using B2C authority.
  /// For more information, follow:
  /// https://learn.microsoft.com/en-us/entra/msal/objc/configure-authority#b2c
  final String? authority;

  /// Type of authority to authenticate against.
  final AuthorityType authorityType;

  /// Authentication middleware that is used to perform authentication.
  /// Only used for iOS platform.
  final Broker broker;

  /// Custom redirect URI for iOS/macOS.
  ///
  /// When null, MSAL derives its own default (msauth.<bundle_id>://auth) and
  /// enforces it. That is a problem for apps whose registered redirect URI does
  /// not match their bundle id: MSAL 2.11+ refuses to create the PCA for a
  /// non-consumer AAD tenant unless the redirect is "broker capable", i.e.
  /// exactly msauth.<bundle_id>://auth — and it returns nil WITHOUT populating
  /// NSError, so the failure surfaces as an opaque
  /// Foundation._GenericObjCError.
  ///
  /// Setting this passes the URI through and turns on MSAL's own
  /// [MSALPublicClientApplicationConfig.bypassRedirectURIValidation], which
  /// skips that check. Brokered authentication is disabled in that case, which
  /// is fine — a redirect that is not broker capable could never use the broker
  /// anyway.
  ///
  /// The URI's scheme must still be registered in Info.plist under
  /// CFBundleURLSchemes, or the callback cannot reach the app.
  final String? redirectUri;

  AppleConfig({
    this.authority,
    this.authorityType = AuthorityType.aad,
    this.broker = Broker.msAuthenticator,
    this.redirectUri,
  });
}

/// Type of authority to authenticate against.
enum AuthorityType {
  /// Microsoft Entra ID (formerly Azure Active Directory).
  aad,

  /// Business-to-Consumer.
  b2c
}

/// Types of broker that is used while authenticating user.
enum Broker {
  /// MS Authenticator app will be used if installed on a device, otherwise
  /// Safari browser will be used.
  msAuthenticator,

  /// Safari browser will be used.
  safariBrowser,

  /// WebView will be used.
  webView,

  /// ASWebAuthenticationSession will be used with an EPHEMERAL (private) web
  /// session: the auth flow gets its own cookie jar, which is discarded when
  /// the session ends.
  ///
  /// Use this when a signed-out user must be able to sign in as SOMEONE ELSE.
  /// [safariBrowser] shares cookies with Safari, so the previous user's Entra
  /// web session stays alive and the next sign-in starts on top of it — MSAL's
  /// `signOut()` only clears the LOCAL token cache, never the browser session.
  ///
  /// NOTE: [safariBrowser] cannot do this. MSAL applies
  /// `prefersEphemeralWebBrowserSession` only to ASWebAuthenticationSession
  /// (MSALWebviewParameters.h) — with SFSafariViewController the flag is
  /// silently ignored.
  ///
  /// Like [safariBrowser] and [webView], this keeps the broker DISABLED
  /// (`MSALGlobalConfig.brokerAvailability = .none`), so it does not require
  /// `LSApplicationQueriesSchemes` in Info.plist.
  ///
  /// iOS/macOS only; ignored on Android.
  ephemeralWebSession
}
