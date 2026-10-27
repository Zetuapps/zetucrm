

# ZetuCRM Mobile App — WhatsApp, Calling, Reminders, Bookings & Notifications Implementation Specification

## 1\. Project Context

We are extending an existing ZetuCRM application. The task is to implement new CRM communication features and bring the existing backend booking functionality into the app.

**Existing backend repository:**

text

```
/Volumes/Dephel01/TASHICO/PROJECTS/WORKS/ZETUAPPS/zetucrm_web
```

**Primary requirement:** The backend is already available. Inspect and reuse its existing functionality, data models, APIs, business logic, authentication, permissions, and booking workflows before introducing anything new if it does not exist implement it there following the codebase structure.

Do not create a separate backend, duplicate the existing booking system, use mock data in production, or store business-critical information exclusively on the device.

The mobile app must retrieve and update information through the existing backend, using the established API and authentication conventions.

## 2\. Primary Objectives

Implement the following features in the existing ZetuCRM app:

1. Quick WhatsApp messaging from CRM contacts.
2. Quick calling from CRM contacts.
3. Persistent call reminders and follow-up management.
4. Incoming-call identification for existing CRM contacts and leads, subject to platform capabilities.
5. A mobile booking experience based on the existing backend booking pages under `/bookings/*`.
6. Backend-driven in-app and push notifications for reminders, bookings, and relevant booking events.
7. Synchronization of contacts, bookings, reminders, notification states, and activity records between the app and backend.

All new functionality must integrate with the existing application architecture and preserve current features.

---

# PHASE 1: Inspect the Existing App and Backend

## 3\. Repository Discovery

Before implementing any code, inspect both the existing mobile app and the backend repository.

Backend path:

text

```
/Volumes/Dephel01/TASHICO/PROJECTS/WORKS/ZETUAPPS/zetucrm_web
```

Identify the mobile app repository from the current workspace and determine its framework, application structure, navigation, authentication, API client, state management, and notification setup.

In the backend, inspect:

- Framework, runtime, project structure, and routing.
- Database engine, schema, models, migrations, and relationships.
- Authentication, authorization, middleware, and tenant isolation, if applicable.
- Contact and lead management.
- Existing APIs and API response formats.
- Booking routes matching `/bookings/*`.
- Booking controllers, services, models, templates, components, and validation rules.
- Booking creation, editing, cancellation, confirmation, availability, and status transitions.
- Existing booking-related notifications, emails, jobs, queues, and scheduled tasks.
- Existing contact activities, call logs, reminders, or notification models.
- Existing push notification infrastructure and device token registration, if any.
- Existing tests, configuration, and environment variables.

Search the backend codebase for the route definitions and trace the complete request lifecycle for each relevant booking workflow.

Do not assume that `/bookings/*` is an API namespace. Determine whether these are server-rendered pages, frontend routes, API routes, or a combination.

## 4\. Architecture and Reuse Rules

After inspecting the codebase:

1. Document the existing booking workflow and how it interacts with the database.
2. Identify which backend APIs already support the app's requirements.
3. Reuse existing APIs, services, models, validation, authorization, and business rules wherever possible.
4. Extend existing backend modules instead of creating duplicate implementations.
5. Add new endpoints or database migrations only where required.
6. Preserve existing web booking behavior and backward compatibility.
7. Follow the established naming conventions, error formats, pagination, and response structure.
8. Use the existing API base URL and environment configuration.
9. Never hardcode production credentials, access tokens, or secrets.
10. Do not overwrite unrelated local changes or perform destructive database operations.

**Important:** If the existing booking pages already implement a feature, use that implementation as the functional reference. Do not independently reinvent its rules in the mobile app.

Deliver a short architecture assessment before making substantial changes, then continue with implementation.

---

# PHASE 2: Quick WhatsApp and Calling

## 5\. WhatsApp Integration

### Requirements

Add a WhatsApp action to appropriate contact surfaces, including:

- Contact list items.
- Contact detail pages.
- Lead details, where a contact phone number exists.
- Booking details when contacting the relevant customer is appropriate.

When a user taps the WhatsApp action:

1. Retrieve the phone number from the current backend-backed contact record.
2. Validate and normalize the number into international format.
3. Open the relevant WhatsApp conversation.
4. Use WhatsApp's supported application or web link behavior.
5. Handle missing numbers, invalid numbers, and unavailable applications gracefully.

Example WhatsApp URL:

text

```
https://wa.me/{international_phone_number}
```

The phone number must be formatted according to WhatsApp's URL requirements, without an international dialing prefix such as `+` in the URL path.

### Optional Pre-filled Messages

Where appropriate, allow the app to open WhatsApp with a pre-filled message relating to a booking or follow-up.

For example:

- Booking confirmation follow-up.
- Appointment reminder.
- General lead follow-up.

Use URL encoding and avoid including sensitive customer information in a message without an appropriate business purpose.

Opening WhatsApp does not mean a message has been sent. Do not mark a notification or follow-up as completed merely because WhatsApp was opened.

## 6\. Quick Calling

Add a call action to contacts and leads.

Requirements:

- Use the backend's current phone number for the selected record.
- Initiate the native phone dialer or supported calling integration.
- Validate phone numbers before invoking the action.
- Provide a suitable fallback when direct calling is unavailable.
- Keep the contact and lead information available in the CRM.
- Record call activities through the backend where the existing architecture and platform integration support reliable call-event data.

Example URL for supported mobile environments:

text

```
tel:{international_phone_number}
```

Do not claim that a call connected, ended, or lasted a specific duration unless the operating system or telephony provider provides reliable information.

---

# PHASE 3: Backend-Persisted Call Reminders

## 7\. Reminder Management

Implement a complete reminder feature, backed by the existing ZetuCRM backend.

**Critical requirement:** Creating a reminder in the app must save it to the backend database. It must not exist only in local application state, local storage, or a device notification scheduler.

Inspect existing reminder, task, activity, and follow-up functionality before creating new models or tables.

If a compatible backend implementation exists, reuse it. Otherwise, extend the backend following its established architecture.

### Reminder Fields

Support the fields appropriate to the existing CRM data model:

- Reminder ID.
- Contact ID.
- Lead ID, when applicable.
- Assigned user ID.
- Reminder title or purpose.
- Notes.
- Scheduled date and time.
- Time zone, where required.
- Status: pending, completed, cancelled, or overdue as appropriate.
- Creation and update timestamps.
- Completion timestamp and outcome, where applicable.

Use existing relationships and conventions instead of duplicating fields unnecessarily.

### Required Operations

Users must be able to:

- Create a call reminder.
- View upcoming reminders.
- View overdue reminders.
- Edit reminder details.
- Reschedule a reminder.
- Complete a reminder.
- Cancel a reminder.
- Open the associated contact or lead.
- Initiate a call or WhatsApp conversation from a reminder.
- Add follow-up notes and outcomes.
- View reminder history where supported.

All operations must use authenticated backend requests and enforce server-side validation and authorization.

### Reminder Workflow

1. A user opens a CRM contact or lead.
2. The user selects **Schedule Call**.
3. The user enters the scheduled date, time, and purpose.
4. The app submits the reminder to the backend.
5. The backend validates the request and persists the reminder.
6. The backend schedules the appropriate notification or registers the reminder with its existing scheduling infrastructure.
7. The app displays the saved reminder and its current status.
8. At the appropriate time, the user receives an in-app notification and a push notification where configured and permitted.
9. The user opens the reminder, calls the contact, and records the outcome.
10. The app submits the updated reminder and activity to the backend.

If the device is offline, show a clear error or a supported pending-sync state. Never display a reminder as successfully saved unless the backend confirms persistence, or explicitly label it as awaiting synchronization.

---

# PHASE 4: Booking Feature Based on `/bookings/*`

## 8\. Booking Feature Discovery

Treat the existing booking implementation in the backend as the authoritative reference for mobile booking behavior.

Repository:

text

```
/Volumes/Dephel01/TASHICO/PROJECTS/WORKS/ZETUAPPS/zetucrm_web
```

Inspect all relevant routes and dependencies associated with `/bookings/*`.

Determine:

- What booking types are supported.
- Which users can view, create, edit, approve, confirm, or cancel bookings.
- Which fields are required for each booking type.
- How customers, contacts, leads, staff, services, and other records relate to bookings.
- How booking availability and conflicts are calculated.
- How booking statuses transition.
- Whether bookings support assignment, resources, locations, or scheduling rules.
- Whether booking confirmation or cancellation triggers existing notifications.
- Whether the backend uses transactions, background jobs, or event handlers.
- Which API endpoints the existing app can already call.

Inspect the existing booking pages and follow their backend data flow rather than merely copying their visual appearance.

## 9\. Implement Bookings in the Mobile App

Create or extend the booking module in the existing app so users can perform the supported booking workflows without relying on a separate web page for routine operations.

Implement the following screens where applicable to the existing system:

### 9.1 Booking List

Display backend-provided bookings with relevant information, such as:

- Booking reference.
- Customer or contact.
- Booking date and time.
- Service, purpose, or booking type.
- Assigned staff or resource, if applicable.
- Current booking status.
- Relevant location or notes.

Support server-backed filtering, search, sorting, and pagination where appropriate.

### 9.2 Booking Details

Display the full booking record returned by the backend, including relevant contact information, status, scheduling details, notes, and associated records permitted for the current user.

Provide actions according to the user's permissions and the booking's current status.

### 9.3 Create Booking

Build a booking form based on the actual backend booking form and validation rules.

Requirements:

- Load selection options from the backend where applicable.
- Use backend-provided availability and scheduling rules.
- Validate required fields.
- Prevent invalid dates and unsupported status transitions.
- Submit the booking through the established API or a new compatible endpoint.
- Display server validation errors clearly.
- Refresh the booking list and relevant detail screens after success.

Do not hardcode customer lists, service lists, available time slots, staff lists, or booking statuses if the backend already supplies this information.

### 9.4 Edit and Manage Bookings

Implement supported operations, such as:

- Update booking information.
- Reschedule a booking.
- Confirm a booking.
- Cancel a booking.
- Change booking status where authorized.
- View booking history or activity where available.

Follow the existing web application's rules for which operations are allowed for each booking status and user role.

Do not implement actions that bypass backend authorization or business rules.

### 9.5 Booking Availability and Conflicts

The backend must remain authoritative for availability and booking conflicts.

- Use existing availability endpoints or services.
- Do not rely exclusively on client-side validation.
- Revalidate availability when the booking is submitted.
- Handle conflicts or slots that become unavailable.
- Display the backend's explanation and offer the user an opportunity to select another time.

### 9.6 Booking Data Synchronization

All booking data must come from the backend.

The mobile app must:

- Fetch booking lists and details through authenticated API requests.
- Send create and update operations to the backend.
- Reflect server-confirmed status changes.
- Refresh affected views after successful mutations.
- Handle loading, empty, error, unauthorized, and offline states.
- Follow the app's existing caching and synchronization conventions.
- Avoid maintaining a separate, conflicting booking database on the device.

If offline access is already supported, use the existing synchronization mechanism and clearly distinguish unsynchronized changes from server-confirmed data.

### 9.7 Preserve Web Booking Behavior

The new mobile experience must not break the existing `/bookings/*` web workflows.

Use shared backend services and business rules where possible. Keep authorization, validation, booking status transitions, and notification triggers consistent across web and mobile clients.

If the existing backend has only server-rendered booking pages and no suitable API, add authenticated API endpoints that call the same underlying services and business logic. Do not scrape the web pages or duplicate the entire booking implementation in the mobile client.

---

# PHASE 5: In-App Notifications

## 10\. Notification Center

Implement an in-app notification experience using the existing backend notification architecture.

Inspect the current notification tables, services, event handlers, and API endpoints before introducing new ones.

### Notification Sources

Support relevant events such as:

- A call reminder is approaching.
- A call reminder is due.
- A call reminder becomes overdue, if supported.
- A booking is created.
- A booking is confirmed.
- A booking is rescheduled.
- A booking is cancelled.
- A booking requires approval or action, if supported.
- A booking is approaching.
- A booking reminder is due.
- A relevant booking or reminder changes status.

Only notify users who should receive the event based on their role, assignment, and notification preferences.

### Notification Center UI

Provide:

- A notification list.
- Read and unread states.
- A badge showing the unread count.
- Notification timestamps.
- Appropriate notification titles and concise messages.
- Navigation to the relevant booking, contact, lead, or reminder.
- A mark-as-read action.
- A mark-all-as-read action if appropriate.
- Pagination or incremental loading when required.

The backend must persist notification records and their read states.

Opening a notification should navigate to the relevant record and fetch the current record from the backend.

Do not assume that the content embedded in an old notification is still up to date.

---

# PHASE 6: Push Notifications

## 11\. Push Notification Infrastructure

Implement push notifications using the technology appropriate to the existing mobile app and backend.

First inspect the existing push notification provider, device registration system, queue infrastructure, and notification services.

Reuse the existing infrastructure wherever possible.

If no push infrastructure exists, select an appropriate provider compatible with the app's actual platforms, such as Firebase Cloud Messaging for supported Android and other integrations, and the applicable Apple Push Notification service integration for iOS.

Do not assume the same configuration works identically on every platform.

### Device Registration

Implement the required device registration workflow:

1. Request notification permission at an appropriate point in the user experience.
2. Obtain the platform's push token when permitted.
3. Register the token with the authenticated backend.
4. Associate the token with the correct user and device.
5. Refresh the token when the provider rotates it.
6. Remove or deactivate invalid tokens when detected.
7. Handle logout and account switching securely.

Follow existing backend conventions for token storage and device management. Do not expose push credentials or server keys in the mobile app.

### Sending Notifications

The backend must trigger push notifications for eligible events.

For reminders:

- Schedule notifications based on the saved reminder time and configured lead time.
- Use the backend's scheduler, job queue, or equivalent infrastructure.
- Respect the user's time zone and configured preferences.
- Avoid sending notifications for reminders that have been cancelled, completed, or rescheduled.
- Revalidate the reminder status before sending a scheduled notification.
- Prevent duplicate notifications for the same event and scheduled occurrence.

For bookings:

- Trigger notifications from the existing booking event lifecycle.
- Notify the relevant users when a booking is created, confirmed, rescheduled, or cancelled, according to the existing workflow and preferences.
- Schedule booking reminders where applicable.
- Cancel or invalidate obsolete scheduled notifications when a booking changes.
- Recheck the current booking state before delivering a scheduled reminder.

### Push Notification Payload

Use a compact payload containing the information necessary to route the user to the correct record.

For example:

json

```
{
  "type": "booking_reminder",
  "booking_id": "BACKEND_BOOKING_ID",
  "notification_id": "BACKEND_NOTIFICATION_ID"
}
```

The values above are illustrative placeholders, not real record IDs or a required final schema. Match the existing backend conventions and provider requirements.

Fetch the latest record from the backend when the user opens the notification. Do not place sensitive customer information in push payloads unnecessarily.

### App Notification Behavior

Handle notifications when the app is:

- Open and in the foreground.
- Running in the background.
- Terminated.
- Opened by tapping a push notification.

Avoid showing duplicate notifications when the same event arrives through both in-app and push channels.

Ensure deep links or internal navigation take the user to the correct booking, contact, lead, or reminder.

Push delivery depends on operating-system permissions, provider configuration, network availability, and device settings. Report delivery status accurately and do not claim that a push notification was delivered merely because the backend queued it.

---

# PHASE 7: Notification Scheduling and Reliability

## 12\. Backend Scheduling

All persistent reminder and booking notification schedules must be controlled by the backend.

Use the existing scheduler, task queue, event system, or job infrastructure if available.

If no suitable infrastructure exists, implement an approach consistent with the backend's runtime and deployment environment.

Requirements:

- Store the reminder or booking in the backend first.
- Schedule the relevant notification after the database transaction succeeds.
- Use durable scheduling or a recoverable job mechanism where available.
- Revalidate the current record and recipient permissions before sending.
- Handle retries and temporary provider failures.
- Prevent duplicate sends with idempotency or an equivalent deduplication strategy.
- Cancel, update, or invalidate jobs when reminder or booking details change.
- Respect user notification preferences and applicable time zones.
- Log failures without exposing sensitive information.
- Provide an appropriate mechanism to recover pending work after service restarts.

If the backend uses database transactions, ensure that notification jobs are not sent for changes that ultimately roll back. Use an existing after-commit mechanism or an appropriate transactional job/outbox pattern.

Do not depend on the mobile app remaining open for reminders or booking notifications to be delivered.

---

# PHASE 8: Incoming-Call Identification

## 13\. Caller Identification

Implement incoming-call identification only to the extent supported by the existing app platform and operating-system policies.

### Requirements

Where supported:

- Detect or receive an incoming caller number through an approved native or telephony integration.
- Normalize the number.
- Match it against backend contacts and leads.
- Display relevant contact or lead information.
- Show the assigned representative, company, or lead status where appropriate.
- Provide a shortcut to open the CRM record.
- Offer an appropriate way to create a contact or lead for an unknown number.
- Avoid exposing records that the current user is not authorized to view.

### Platform Limitations

**Android:** Investigate the relevant native APIs, call-screening roles, caller identification mechanisms, and overlay restrictions for the target Android versions. Request only necessary permissions and follow distribution policies.

**iOS:** Investigate supported CallKit and Call Directory capabilities. Do not promise unrestricted real-time overlays on incoming cellular calls.

**Web application:** Use supported alternatives such as contact lookup, browser notifications, or an approved cloud telephony integration.

**Cloud telephony or VoIP:** If the existing business phone system provides incoming-call events, integrate with its supported webhooks and authentication mechanisms.

Do not attempt to bypass platform restrictions, collect call information without appropriate permission, or claim universal caller identification support.

If the existing mobile app cannot support this feature directly, document the additional native integration or provider needed and implement a supported alternative.

---

# PHASE 9: Backend API and Database Requirements

## 14\. API Design

Inspect the current API before designing new endpoints.

Reuse existing endpoints wherever possible. Add endpoints only for functionality that is missing.

The following are conceptual API capabilities, not instructions to create duplicate routes when equivalent endpoints already exist.

| Capability | Required behavior |
| --- | --- |
| Contacts and leads | Retrieve authorized records and phone numbers |
| Reminders | Create, list, retrieve, update, complete, cancel, and reschedule |
| Bookings | List, retrieve, create, edit, confirm, reschedule, and cancel where supported |
| Availability | Retrieve valid options and validate booking conflicts |
| Notifications | List notifications, retrieve unread counts, mark read, and mark all read where supported |
| Push registration | Register, refresh, and deactivate device tokens |
| Activities | Save permitted call outcomes, notes, and follow-up history |
| Caller lookup | Match normalized numbers against authorized CRM records where required |

Follow the backend's existing route naming, response envelope, validation error structure, pagination, and authentication requirements.

Do not expose unrestricted caller lookup or notification endpoints.

## 15\. Database and Data Integrity

Inspect the current database before adding or modifying tables.

Reuse existing models and relationships when suitable.

If new storage is required, implement proper migrations and relationships for:

- Reminders and their associated CRM records.
- Persistent notification records and read states.
- Device push registrations.
- Notification scheduling or delivery tracking, where needed.
- Call activities, only when not already supported.

Apply the existing tenant isolation, ownership, access control, indexing, soft-delete, and audit conventions.

Requirements:

- Use backend-generated identifiers.
- Validate foreign keys and record ownership.
- Prevent unauthorized cross-user or cross-tenant access.
- Keep booking and reminder status transitions consistent.
- Use database transactions where multiple related changes must succeed together.
- Avoid duplicate notification records and duplicate event processing.
- Preserve existing records and compatibility with the web app.
- Do not store secrets in application tables unnecessarily.

Do not create new tables merely because they appear in this specification. First establish whether the backend already has suitable structures.

---

# PHASE 10: Security and Permissions

## 16\. Security Requirements

All new backend operations must use the existing authentication and authorization system.

Enforce permissions on the server, not only by hiding app buttons.

Requirements:

- Validate the authenticated user for every protected request.
- Verify access to each contact, lead, reminder, booking, and notification.
- Enforce tenant boundaries where applicable.
- Validate submitted dates, identifiers, statuses, and other input.
- Prevent users from changing records assigned to unauthorized users.
- Protect push tokens and provider credentials.
- Avoid logging sensitive customer information.
- Use secure transport for production API requests.
- Handle expired sessions and unauthorized responses correctly.
- Avoid leaking customer information through notification previews or caller identification.

Review platform permissions carefully, especially for push notifications, caller identification, phone access, and overlays.

---

# PHASE 11: Mobile User Experience

## 17\. Navigation and UI

Integrate these features into the existing app navigation and design system.

Prefer the existing components, typography, colors, spacing, icons, and interaction patterns.

Add or extend the following areas as appropriate:

- Contact details with WhatsApp and call actions.
- Lead details with communication and follow-up actions.
- Call reminders and follow-up list.
- Booking list.
- Booking details.
- Booking creation and editing.
- Notification center.
- Notification preferences, where supported.

Include:

- Loading indicators.
- Empty states.
- Clear validation messages.
- Retry options for recoverable errors.
- Confirmation for destructive actions.
- Appropriate success and failure feedback.
- Accessible controls.
- Responsive layouts.

Do not build duplicate navigation structures or replace unrelated screens unnecessarily.

---

# PHASE 12: Testing and Verification

## 18\. Backend Tests

Add or update automated tests covering:

- Reminder creation and persistence.
- Reminder editing, cancellation, completion, and rescheduling.
- Reminder authorization.
- Booking creation and retrieval.
- Booking status transitions.
- Booking availability and conflict detection.
- Existing `/bookings/*` workflow compatibility.
- Notification creation and read states.
- Push token registration and deactivation.
- Notification scheduling and cancellation.
- Duplicate-event prevention.
- Unauthorized access and tenant isolation.
- Invalid input and server error handling.

## 19\. Mobile Tests

Test:

- Opening WhatsApp from a contact.
- Initiating a supported call action.
- Creating and updating reminders.
- Refreshing backend-backed reminder data.
- Loading bookings from the backend.
- Creating, editing, and cancelling bookings.
- Displaying backend validation and conflict errors.
- Opening notifications and navigating to the correct record.
- Handling notification permissions.
- Handling foreground, background, and terminated-app push interactions where supported.
- Handling network failures and expired authentication.
- Preventing duplicate notification presentation.

## 20\. Integration Tests

Verify the complete end-to-end workflows.

### Reminder workflow

1. Create a reminder from the app.
2. Verify the record exists in the backend database.
3. Verify it is associated with the correct contact, lead, and user.
4. Verify the notification job is scheduled.
5. Verify the appropriate in-app notification and push dispatch occur at the expected time, using a test environment.
6. Reschedule or cancel the reminder.
7. Verify the old schedule no longer produces an inappropriate notification.
8. Complete the reminder and verify the backend status and activity history.

### Booking workflow

1. Open the booking list in the app.
2. Verify that records come from the existing backend.
3. Create a booking using valid backend-provided options.
4. Verify that the booking is persisted in the existing database.
5. Verify that the existing web booking workflow remains functional.
6. Update or reschedule the booking.
7. Verify that availability and conflicts are enforced by the backend.
8. Verify that the appropriate notification records and push jobs are generated.
9. Cancel the booking.
10. Verify that stale scheduled notifications are cancelled or invalidated.
11. Open the relevant booking from a notification and verify that the latest backend state is displayed.

Use a test environment and test records for these workflows.

---

# PHASE 13: Implementation Order

## 21\. Required Execution Sequence

Implement in the following order to reduce risk:

### Stage 1 — Discovery

- Identify the mobile app framework and repository structure.
- Inspect the backend repository.
- Map `/bookings/*` routes and their complete data flow.
- Inspect existing APIs, models, authentication, and notifications.
- Document reuse opportunities and missing functionality.

### Stage 2 — Backend Foundation

- Reuse or implement the required reminder and notification capabilities.
- Extend booking APIs only where needed.
- Implement persistence, validation, authorization, and migrations.
- Implement durable scheduling and notification event handling.

### Stage 3 — Mobile API Integration

- Reuse the app's existing API client.
- Implement typed models or equivalent data structures.
- Integrate reminders, bookings, and notification APIs.
- Implement error handling and refresh behavior.

### Stage 4 — Communication Features

- Add WhatsApp actions.
- Add quick calling.
- Add reminder creation and follow-up management.
- Record supported call outcomes.

### Stage 5 — Booking Experience

- Implement booking list and detail screens.
- Implement supported create, edit, and status workflows.
- Integrate availability, validation, and conflict handling.
- Verify parity with the existing web booking behavior.

### Stage 6 — Notifications

- Implement the in-app notification center.
- Implement device registration and push delivery where required.
- Integrate reminder and booking events.
- Verify navigation and duplicate prevention.

### Stage 7 — Caller Identification

- Determine platform feasibility.
- Implement the approved native or telephony integration if supported.
- Otherwise, implement the best supported alternative and document limitations.

### Stage 8 — Testing and Delivery

- Run backend and mobile tests.
- Run relevant migrations in the appropriate environment.
- Verify end-to-end workflows.
- Document setup and deployment requirements.
- Report completed work and remaining blockers.

---

# PHASE 14: Definition of Done

## 22\. Acceptance Criteria

### WhatsApp and Calling

- [ ]WhatsApp can be opened from a supported contact or lead screen.
- [ ]Quick calling works through the supported device or telephony integration.
- [ ]Missing and invalid phone numbers are handled gracefully.

### Reminders

- [ ]Reminders are saved in the existing backend database.
- [ ]Users can view, edit, reschedule, complete, and cancel reminders.
- [ ]Reminders remain available after restarting or reinstalling the app, subject to account access and backend retention.
- [ ]Reminder authorization and contact relationships are enforced by the backend.

### Bookings

- [ ]The agent has inspected the actual `/bookings/*` implementation.
- [ ]The app retrieves booking data from the existing backend.
- [ ]The app supports the applicable booking workflows already provided by the web system.
- [ ]Booking availability, validation, and status rules remain server-authoritative.
- [ ]Existing web booking workflows continue to function.
- [ ]Booking changes are reflected correctly in the app.

### Notifications

- [ ]In-app notifications are persisted in the backend.
- [ ]Read states and unread counts are synchronized with the backend.
- [ ]Push notifications use the appropriate platform provider.
- [ ]Reminder and booking notifications follow current record state.
- [ ]Rescheduled or cancelled records do not trigger obsolete reminders.
- [ ]Duplicate notification delivery is controlled.
- [ ]Tapping a notification opens the correct record.

### Caller Identification

- [ ]The supported implementation can match caller numbers against authorized CRM records where platform capabilities allow.
- [ ]Platform restrictions and required permissions are documented.
- [ ]Unsupported functionality is not represented as complete.

### Quality

- [ ]Existing application behavior is preserved.
- [ ]Backend and mobile tests pass, or remaining failures are documented.
- [ ]Required migrations and configuration changes are documented.
- [ ]No production secrets are committed.
- [ ]No mock or hardcoded business data is used in production workflows.

---

# PHASE 15: Final Deliverables

## 23\. Required Final Report

After implementation, provide a concise but complete report containing:

1. **Architecture findings:** The mobile framework, backend framework, database, API approach, and relevant existing booking and notification implementations.
2. **Existing functionality reused:** Identify the booking services, APIs, models, and notification components reused.
3. **Backend changes:** List modified and newly created files, migrations, routes, services, jobs, and models.
4. **Mobile changes:** List modified and newly created screens, components, models, API services, and navigation changes.
5. **Booking parity:** Explain which `/bookings/*` workflows are available in the app.
6. **Notification setup:** Explain required push-provider configuration, credentials, device registration, and scheduler or queue setup without exposing secrets.
7. **Testing:** Report the actual tests executed and their results.
8. **Deployment instructions:** Explain migration, backend deployment, mobile configuration, and required environment variables.
9. **Limitations:** Identify features requiring additional native integration, provider access, platform permissions, or infrastructure.
10. **Outstanding work:** List anything incomplete and why.

## Final Instruction to the Coding Agent

Implement this specification directly in the existing ZetuCRM app and the existing backend repository:

text

```
/Volumes/Dephel01/TASHICO/PROJECTS/WORKS/ZETUAPPS/zetucrm_web
```

Begin by inspecting the repositories and tracing the existing `/bookings/*` implementation. Reuse the current backend as the source of truth for contacts, bookings, reminders, notifications, permissions, and related business data.

Implement backend persistence and server-side notification scheduling before relying on the corresponding mobile screens. The app must read and write through the established backend APIs, and all booking operations must follow the existing web application's business rules.

Do not stop after writing a plan or generating UI mockups. Make the actual code changes, add the required migrations and tests, run the available verification steps, and report what was implemented.

Do not invent repository files, API endpoints, environment variables, database tables, or successful test results. Discover the actual implementation first, preserve existing functionality, and document any genuine blockers.

### Important implementation note

The key correction in this version is that the backend is the source of truth. Reminders, booking changes, notification records, and scheduling must be persisted and managed server-side. The mobile app is the interface for those backend features, not a separate system with its own disconnected data, if it does not exist implement it there following the same pattern as already implemented features.

The absolute backend path is included exactly as provided. Your coding agent must be able to access that local filesystem path from its execution environment; if it cannot, it should report the access limitation rather than pretending to have scanned the repository.