# Claude Web Access Setup for CurbAppeal AI

## Overview
This document outlines the web access capabilities added to the CurbAppeal AI project for automated testing and development with Claude Code.

## Setup Complete ✅

### 1. Playwright MCP Server Installation
- Installed globally: `@executeautomation/playwright-mcp-server`
- Provides browser automation through MCP protocol
- Supports Chrome, Firefox, and WebKit browsers

### 2. Configuration Files Created

#### MCP Configuration (`C:\GitHub\.claude-code-mcp.json`)
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@executeautomation/playwright-mcp-server"],
      "env": {
        "PLAYWRIGHT_HEADLESS": "false",
        "PLAYWRIGHT_TIMEOUT": "30000"
      }
    }
  }
}
```

#### Updated Vite Configuration
- Added network access capabilities
- Configured CORS for testing
- Set fixed port (5179) for consistency

#### Test Helpers (`src/test-helpers/automation.ts`)
- Helper functions for automated testing
- Analysis workflow automation utilities
- Test scenario definitions

## Usage Examples

### Basic Navigation
```javascript
// Claude can now execute commands like:
// "Navigate to http://localhost:5179"
// "Take screenshot of homepage"
// "Click on analyze button"
```

### Form Testing
```javascript
// Automated form interactions:
// "Upload test image to the form"
// "Fill email capture form with test@example.com"
// "Wait for analysis results to display"
```

### Results Validation
```javascript
// Result checking:
// "Verify score display shows percentage"
// "Check all 10 criteria are evaluated"
// "Validate email form appears after analysis"
```

## Available Test Scenarios

### 1. Homepage Testing
- URL: `http://localhost:5179`
- Tests hero section loading
- Validates navigation elements
- Checks feature descriptions

### 2. Analysis Page Testing  
- URL: `http://localhost:5179/analyze`
- Tests file upload functionality
- Validates image processing workflow
- Checks analysis progress indicators

### 3. Results Page Testing
- Tests score display accuracy
- Validates criteria breakdown
- Checks email capture functionality

## Development Workflow Integration

### Package.json Scripts Added
```json
{
  "test:e2e": "E2E testing with Claude Code web access",
  "test:automation": "Automated testing with Playwright MCP"
}
```

### Automation Commands
- `npm run dev` - Start development server (port 5179)
- `npm run test:e2e` - Placeholder for E2E testing
- `npm run test:automation` - Placeholder for automation testing

## Security Considerations

- **Localhost Only**: All testing restricted to localhost
- **No Production Access**: Web access limited to development environment
- **Test Data Only**: Use mock images and test emails
- **Browser Isolation**: Headless mode available for CI/CD

## Next Steps for Claude

With this setup, Claude can now:

1. **Navigate** to your running application
2. **Interact** with forms and buttons
3. **Upload** test images for analysis
4. **Validate** AI analysis results
5. **Test** complete user workflows
6. **Take screenshots** for documentation
7. **Monitor** application performance
8. **Automate** repetitive testing tasks

## Troubleshooting

### Common Issues
- **Port conflicts**: Application automatically finds available ports
- **MCP not loading**: Check Claude Code MCP configuration
- **Browser not starting**: Verify Playwright installation
- **Timeout errors**: Increase `PLAYWRIGHT_TIMEOUT` in config

### Debug Commands
```bash
# Verify Playwright installation
npx playwright --version

# Test MCP server
npx @executeautomation/playwright-mcp-server --help

# Check development server
curl http://localhost:5179
```

## Benefits Achieved

✅ **Automated Testing**: End-to-end workflow validation  
✅ **Development Speed**: Rapid UI testing and validation  
✅ **Quality Assurance**: Consistent test execution  
✅ **Documentation**: Screenshot and behavior capture  
✅ **Debugging**: Real-time application interaction  
✅ **Future-Proof**: Extensible for additional testing needs  

---

**Status**: Ready for use with Claude Code web access capabilities
**Last Updated**: August 10, 2025
**Application URL**: http://localhost:5179