# hubspot-upsert-contact

This hook upserts contact records in HubSpot after every tool use. When the agent processes data containing contact information — email addresses, names, job titles, LinkedIn URLs — this hook extracts that data and creates or updates the corresponding HubSpot contact, ensuring your CRM reflects what the agent researches or produces.

## When it fires

Fires on the `PostToolUse` event, which triggers after every tool the agent uses successfully.

## What it runs

```
orchestrator/run.sh hubspot upsert
```

The script parses the tool result payload for contact signals and calls the HubSpot Contacts API to upsert the record using email as the unique key.

## Required environment variables

| Variable | Description |
|---|---|
| `HUBSPOT_ACCESS_TOKEN` | Private app access token from your HubSpot developer settings |

## Optional environment variables

| Variable | Description |
|---|---|
| `HUBSPOT_CONTACT_OWNER_ID` | HubSpot user ID to assign as contact owner on creation |
| `HUBSPOT_CONTACT_LIFECYCLE_STAGE` | Lifecycle stage to set on newly created contacts (e.g. `lead`, `subscriber`) |
