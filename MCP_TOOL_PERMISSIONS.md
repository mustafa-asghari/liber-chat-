# MCP Tool Permissions Guide for CaloriesAI API

## Overview
This document outlines the required permissions and improvements needed for the MCP tool in your Python API (`caloriesaiproject-production.up.railway.app`) to work correctly with LibreChat.

## Current Issues
1. **Duplicate Entries**: The AI keeps creating duplicate daily totals instead of replacing old ones
2. **Incorrect Calculations**: Totals are not being calculated correctly
3. **Missing Fields**: Healthy Fat and Unhealthy Fat fields are sometimes missing
4. **No Delete Permission**: The AI cannot properly delete old entries before inserting new ones

## Required MCP Tool Permissions

Your MCP tool MUST have full CRUD (Create, Read, Update, Delete) permissions:

### 1. **READ/QUERY Permission**
- ✅ Should be able to query all entries for a specific date
- ✅ Should be able to query individual meals
- ✅ Should be able to query daily totals
- ✅ Should return complete data including all fields

### 2. **DELETE Permission** (CRITICAL)
- ✅ Should be able to delete ALL entries for a specific date
- ✅ Should be able to delete individual meals
- ✅ Should be able to delete daily totals
- ✅ Should support bulk delete operations

### 3. **INSERT/CREATE Permission**
- ✅ Should be able to insert new meals
- ✅ Should be able to insert daily totals
- ✅ Should validate all required fields before insertion

### 4. **UPDATE Permission**
- ✅ Should be able to update existing entries
- ✅ Should be able to update totals

## Database Structure Requirements

The MCP tool MUST support this exact structure for daily totals:

```json
{
  "Date": "2025-11-10",  // String format: YYYY-MM-DD
  "Total Calories": 974,  // Number
  "Total Protein (g)": 69,  // Number
  "Total Carbs (g)": 82,  // Number
  "Total Fat (g)": 32,  // Number
  "Healthy Fat (g)": 20,  // Number (REQUIRED)
  "Unhealthy Fat (g)": 12  // Number (REQUIRED)
}
```

## Recommended MCP Tool Implementation

### Tool 1: `query_daily_entries`
**Purpose**: Query all entries for a specific date
**Parameters**:
- `date` (string, required): Date in YYYY-MM-DD format
- `entry_type` (string, optional): "meal", "total", or "all" (default: "all")

**Returns**: Array of all entries matching the date

### Tool 2: `delete_daily_entries` (CRITICAL)
**Purpose**: Delete all entries for a specific date
**Parameters**:
- `date` (string, required): Date in YYYY-MM-DD format
- `entry_type` (string, optional): "meal", "total", or "all" (default: "all")

**Returns**: Confirmation of deletion and count of deleted entries

### Tool 3: `insert_daily_total`
**Purpose**: Insert a new daily total entry
**Parameters**:
- `date` (string, required): Date in YYYY-MM-DD format
- `total_calories` (number, required)
- `total_protein` (number, required)
- `total_carbs` (number, required)
- `total_fat` (number, required)
- `healthy_fat` (number, required)
- `unhealthy_fat` (number, required)

**Returns**: Confirmation of insertion

### Tool 4: `insert_meal`
**Purpose**: Insert a new meal entry
**Parameters**:
- `date` (string, required): Date in YYYY-MM-DD format
- `name` (string, required): Meal name
- `calories` (number, required)
- `protein` (number, required)
- `carbs` (number, required)
- `fat` (number, required)
- `healthy_fat` (number, required)
- `unhealthy_fat` (number, required)
- `ingredients` (string, optional)

**Returns**: Confirmation of insertion

### Tool 5: `calculate_and_update_total`
**Purpose**: Calculate totals from all meals for a date and update the daily total
**Parameters**:
- `date` (string, required): Date in YYYY-MM-DD format

**Returns**: Updated daily total with calculated values

## Workflow for Updating Daily Totals

The AI should follow this exact workflow:

1. **Query**: Call `query_daily_entries(date)` to see what exists
2. **Delete**: Call `delete_daily_entries(date, "total")` to remove old totals
3. **Calculate**: Sum all meal entries to get correct totals
4. **Insert**: Call `insert_daily_total()` with calculated values
5. **Verify**: Call `query_daily_entries(date)` again to confirm only one total exists

## Example MCP Tool Schema

```json
{
  "name": "delete_daily_entries",
  "description": "Delete all entries (meals and/or totals) for a specific date. CRITICAL: Use this before inserting new totals to prevent duplicates.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "date": {
        "type": "string",
        "description": "Date in YYYY-MM-DD format (e.g., '2025-11-10')"
      },
      "entry_type": {
        "type": "string",
        "enum": ["meal", "total", "all"],
        "description": "Type of entries to delete: 'meal' for meals only, 'total' for totals only, 'all' for both",
        "default": "all"
      }
    },
    "required": ["date"]
  }
}
```

## Testing Checklist

Before deploying, ensure:
- [ ] Tool can query entries by date
- [ ] Tool can delete entries by date
- [ ] Tool can delete all entries for a date (bulk delete)
- [ ] Tool can insert daily totals with all required fields
- [ ] Tool validates that Healthy Fat + Unhealthy Fat = Total Fat
- [ ] Tool prevents duplicate totals for the same date (or allows deletion first)
- [ ] Tool returns clear error messages if operations fail

## Next Steps

1. Update your Python API MCP tool to include full DELETE permissions
2. Ensure all tools return complete data including Healthy Fat and Unhealthy Fat
3. Test the workflow: Query → Delete → Insert → Verify
4. Deploy the updated API
5. Test with LibreChat to ensure duplicates are prevented

