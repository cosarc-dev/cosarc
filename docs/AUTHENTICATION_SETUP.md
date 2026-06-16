# Cosarc Authentication Setup

Production-ready authentication using Supabase Auth. All flows are implemented in `lib/services/auth_service.dart` and wired to premium UI screens.

## Supported Sign-In Methods

| Method | Screen | Implementation |
|--------|--------|----------------|
| Email + Password | `login_screen.dart`, `signup_screen.dart` | `signIn`, `signUp`, `updatePassword` |
| Email OTP | `login_screen.dart` → `otp_verification_screen.dart` | `sendEmailOtp`, `verifyOtp` |
| Phone OTP | `phone_auth_screen.dart` → `otp_verification_screen.dart` | `sendPhoneOtp`, `verifyOtp` |
| Google | Login social orb | Native: `google_sign_in` + `signInWithIdToken`; Web: OAuth |
| Apple | Login social orb (iOS/macOS) | `sign_in_with_apple` + `signInWithIdToken` |
| TOTP MFA | `mfa_challenge_screen.dart`, `two_factor_settings_screen.dart` | Supabase MFA enroll/verify/challenge |

## Email OTP Setup (Supabase Dashboard)

1. Open **Authentication → Providers → Email**
2. Enable **Email OTP** (magic link / OTP sign-in)
3. Configure SMTP under **Project Settings → Auth → SMTP** for production email delivery
4. Default Supabase dev project sends via Supabase mailer (rate-limited)

**App usage:** Login → toggle "Sign in with email code" → `sendEmailOtp` → `OtpVerificationScreen` → `verifyOtp`.

## SMS / Phone OTP Setup

1. Open **Authentication → Providers → Phone**
2. Enable Phone provider
3. Configure an SMS provider (Twilio, MessageBird, Vonage, or Textlocal)
4. Add provider credentials in Supabase dashboard

**App usage:** Login → Phone orb → `PhoneAuthScreen` → SMS OTP → `OtpVerificationScreen`.

## Google Sign-In Setup

**Supabase:**
1. Authentication → Providers → Google → Enable
2. Add OAuth client ID and secret from Google Cloud Console

**Android:** Add SHA-1 to Firebase/Google Cloud, configure `google-services.json` if used.

**iOS:** Add reversed client ID to URL schemes.

**Web:** OAuth redirect URL must match Supabase callback URL.

## Apple Sign-In Setup

**Supabase:**
1. Authentication → Providers → Apple → Enable
2. Add Apple Services ID, Team ID, Key ID, and private key

**iOS:** Enable Sign in with Apple capability in Xcode.

**Note:** Apple Sign-In is available on login only (iOS/macOS native).

## MFA (TOTP) Setup

**Supabase:**
1. Authentication → Multi-Factor → Enable TOTP
2. Set AAL (Authenticator Assurance Level) policies as needed

**App flows:**
- **Enrollment:** Profile → Privacy & Security → Two-factor authentication → scan QR → verify code
- **Challenge:** After login, if AAL2 required → `MfaChallengeScreen`
- **Recovery:** Sign out everywhere via Security settings; re-enroll TOTP from 2FA settings

**SMS MFA reverify:** Requires phone on account. Add phone via Phone auth first; SMS reverify shows guidance in `two_factor_settings_screen.dart`.

## Environment

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

## Production Checklist

- [ ] SMTP configured for email OTP
- [ ] SMS provider configured for phone OTP
- [ ] Google OAuth credentials (all platforms)
- [ ] Apple Sign-In credentials (iOS)
- [ ] TOTP MFA enabled in Supabase
- [ ] Redirect URLs whitelisted
- [ ] Rate limits reviewed

## Important

The app does **not** fake OTP verification. All OTP flows call real Supabase Auth APIs. If providers are not configured, users receive Supabase error messages surfaced via `friendlyAuthError()`.
