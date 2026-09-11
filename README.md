# Maa Saraswati Public School — Simple Dynamic Website

## Final scope

This version intentionally does **NOT** include:
- student login
- parent login
- attendance
- marks/results
- school ERP
- fee management
- teacher management
- complicated school-management modules

It is a **Class XII school information website** with one simple backend/CMS.

## Technology

- Flutter — responsive web UI
- Node.js + Express — backend REST API
- PostgreSQL — database
- JWT + bcrypt — admin authentication

## Public website

- Home
- About
- Academics
- Admissions
- Student Life
- School Events
- Rules & Guidelines
- Gallery
- Contact
- Admission enquiry form
- Contact form

## Admin panel

One admin login.

The administrator can change:
- Home heading
- Home description
- About-school content
- Academics content
- Student-life content
- Rules/guidelines
- Events

The admin can also view:
- Admission enquiries
- Contact messages

No source-code editing is required for normal content changes.

## Setup

### PostgreSQL

Create:

```sql
CREATE DATABASE maa_saraswati_school;
```

Import:

```text
backend/schema.sql
```

### Backend

```bash
cd backend
npm install
```

Copy `.env.example` to `.env`.

Example:

```env
PORT=5000
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/maa_saraswati_school
JWT_SECRET=use-a-long-random-secret
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your-admin-password
```

Then:

```bash
npm run seed
npm start
```

### Flutter

```bash
cd flutter_app
flutter pub get
flutter run -d chrome
```

For another API address:

```bash
flutter run -d chrome --dart-define=API_URL=https://your-domain.com/api
```

## Admin

Open the Admin Login route from:

```text
/admin
```

For local Flutter web this is available through the app's admin route.

Change the default admin password before deployment.

## Publishing

For production:
1. Deploy Node.js API.
2. Deploy PostgreSQL.
3. Configure HTTPS.
4. Set the production API URL in Flutter.
5. Build Flutter web:

```bash
flutter build web --dart-define=API_URL=https://your-domain.com/api
```

6. Host the generated `build/web` folder.

## Important

All school information, dates, fees, rules and contact details should be verified by the school before public launch.
