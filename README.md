# Kitties FTW

A private social sharing app for parents to safely share videos and photos with their kids.

Live at [kittiesftw.com](https://kittiesftw.com)

---

## Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Web) |
| Backend | Supabase (database, storage, auth) |
| Email | Resend |
| Hosting | Vercel |

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Supabase CLI](https://supabase.com/docs/guides/cli) *(optional, for local dev)*
- A Supabase project
- A Resend account and API key
- A Vercel account

---

## Environment Setup

Create a `.env` file (or set environment variables in Vercel) with the following:

```
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
RESEND_API_KEY=your_resend_api_key
```

> ⚠️ Never commit `.env` to version control.

---

## Local Development

```bash
# Install dependencies
flutter pub get

# Run in Chrome (web)
flutter run -d chrome
```

---

## Deployment

The app is deployed to Vercel. Pushes to `main` trigger automatic deploys.

```bash
# Build for web
flutter build web

# Deploy manually (if not using Vercel Git integration)
vercel --prod
```

---

## Project Structure

```
lib/
  core/          # Shared utilities, constants, dependency injection
  features/      # Feature modules (auth, feed, upload, etc.)
  main.dart      # App entry point
```

*Update this section as the structure evolves.*

---

## Contributing

*Coming soon — contribution guidelines will be added when the project opens to collaborators.*

---

## License

*TBD*
