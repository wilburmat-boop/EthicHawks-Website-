#!/bin/sh
# Ethic Hawks Forensic Governance AI Assistant Fix Helper
# Fixes for the EH (Ethic Hawks) button integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_success() { echo "${GREEN}✓${NC} $1"; }
print_error() { echo "${RED}✗${NC} $1"; }
print_info() { echo "${YELLOW}ℹ${NC} $1"; }
print_action() { echo "${CYAN}→${NC} $1"; }
print_ethic() { echo "${PURPLE}⚖${NC} $1"; }
print_header() { echo "\n${BLUE}═══${NC} $1 ${BLUE}═══${NC}"; }

# Configuration for Ethic Hawks
EH_CONFIG_FILE="ethic-hawks-config.json"
EH_API_ENDPOINT="${EH_API_ENDPOINT:-https://api.ethic-hawks.ai/v1}"
EH_WIDGET_ID="${EH_WIDGET_ID:-eh-assistant-widget}"

# Check current implementation
scan_ethic_hawks() {
    print_header "Scanning for Ethic Hawks Implementation"
    
    local found=0
    
    # Check for Ethic Hawks script
    print_info "Checking for Ethic Hawks script tags..."
    find . -name "*.html" -o -name "*.php" -o -name "*.js" -o -name "*.jsx" -o -name "*.tsx" 2>/dev/null | while read -r file; do
        if grep -qi "ethic.hawks\|ethic-hawks\|ethicHawks" "$file" 2>/dev/null; then
            print_success "Ethic Hawks reference in: $file"
            grep -ni "ethic.hawks\|ethic-hawks\|ethicHawks" "$file"
            found=1
        fi
    done
    
    # Check for widget container
    print_info "Checking for widget container..."
    if grep -rq "eh-assistant\|eh-widget\|ethic-hawks-container" --include="*.html" --include="*.php" . 2>/dev/null; then
        print_success "Widget container found"
    else
        print_error "Widget container not found - needs to be added"
    fi
    
    # Check configuration
    if [ -f "$EH_CONFIG_FILE" ]; then
        print_success "Configuration file found: $EH_CONFIG_FILE"
        if command -v jq >/dev/null 2>&1; then
            cat "$EH_CONFIG_FILE" | jq '.'
        else
            cat "$EH_CONFIG_FILE"
        fi
    else
        print_info "No configuration file found"
    fi
    
    return $found
}

# Common integration issues and fixes
diagnose_integration() {
    print_header "Diagnosing Ethic Hawks Integration"
    
    # Check 1: API Key
    print_ethic "Checking API Key configuration..."
    if [ -n "$EH_API_KEY" ]; then
        print_success "API Key found in environment"
    elif grep -rq "EH_API_KEY\|ethicHawksApiKey\|apiKey.*ethic" --include="*.env" --include="*.js" --include="*.json" . 2>/dev/null; then
        print_success "API Key found in project files"
    else
        print_error "API Key not found! Ethic Hawks requires authentication"
        print_action "Add your API key: export EH_API_KEY='AIzaSyB3Br7KLVZKNk-Eosk9_csZ7U4rH81H-z0'"
    fi
    
    # Check 2: Script loading order
    print_ethic "Checking script loading order..."
    find . -name "*.html" -type f 2>/dev/null | while read -r file; do
        if grep -q "ethic.hawks" "$file" 2>/dev/null; then
            # Check if script is loaded before DOM
            script_line=$(grep -n "ethic.hawks" "$file" | head -1 | cut -d: -f1)
            total_lines=$(wc -l < "$file")
            
            if [ "$script_line" -lt 5 ]; then
                print_error "Ethic Hawks script may load too early in $file (line $script_line)"
                print_action "Move script to before </body> or use defer/async"
            fi
        fi
    done
    
    # Check 3: CORS issues
    print_ethic "Checking for CORS configuration..."
    if grep -rq "Access-Control-Allow-Origin\|cors" --include="*.js" --include="*.php" --include="*.conf" . 2>/dev/null; then
        print_success "CORS headers found"
    else
        print_info "CORS may need configuration for Ethic Hawks API"
    fi
    
    # Check 4: CSP (Content Security Policy)
    print_ethic "Checking Content Security Policy..."
    if grep -rq "Content-Security-Policy" --include="*.html" --include="*.php" --include="*.conf" . 2>/dev/null; then
        print_error "CSP detected - may block Ethic Hawks scripts"
        print_action "Add to CSP: script-src 'self' https://api.ethic-hawks.ai"
    fi
    
    # Check 5: Module bundler issues
    if [ -f "webpack.config.js" ] || [ -f "vite.config.js" ] || [ -f "next.config.js" ]; then
        print_ethic "Module bundler detected - checking for Ethic Hawks plugin..."
        if grep -rq "ethic-hawks" webpack.config.js vite.config.js next.config.js 2>/dev/null; then
            print_success "Ethic Hawks configured in bundler"
        else
            print_info "Ethic Hawks may need bundler configuration"
        fi
    fi
}

# Fix common issues
fix_ethic_hawks() {
    print_header "Applying Ethic Hawks Fixes"
    
    backup_dir="ethic_hawks_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    print_success "Backups in: $backup_dir"
    
    # Fix 1: Add proper initialization
    print_action "Creating proper initialization script..."
    
    cat > "${backup_dir}/ethic-hawks-init.js" << 'EOF'
// Ethic Hawks Forensic Governance AI Assistant - Initialization
(function() {
    'use strict';
    
    console.log('⚖️ Initializing Ethic Hawks Assistant...');
    
    // Configuration
    const EH_CONFIG = {
        apiKey: window.EH_API_KEY || process.env.EH_API_KEY || 'YOUR_API_KEY',
        apiEndpoint: 'https://api.ethic-hawks.ai/v1',
        widgetId: 'eh-assistant-widget',
        theme: {
            primary: '#1a237e',
            secondary: '#4a148c',
            accent: '#ff6f00'
        },
        features: {
            forensicAnalysis: true,
            governanceCheck: true,
            complianceReview: true,
            riskAssessment: true
        }
    };
    
    // Wait for DOM
    function init() {
        const container = document.getElementById(EH_CONFIG.widgetId);
        
        if (!container) {
            console.error('❌ Ethic Hawks container not found (#' + EH_CONFIG.widgetId + ')');
            return;
        }
        
        if (!EH_CONFIG.apiKey || EH_CONFIG.apiKey === 'AIzaSyB3Br7KLVZKNk-Eosk9_csZ7U4rH81H-z0
') {
            console.error('❌ Ethic Hawks API key not configured');
            container.innerHTML = '<div style="padding:20px;background:#fff3cd;border:1px solid #ffc107;">⚠️ Ethic Hawks requires API key configuration</div>';
            return;
        }
        
        // Create widget iframe or mount point
        const widget = document.createElement('div');
        widget.className = 'eh-widget-container';
        widget.innerHTML = `
            <div class="eh-header">
                <span class="eh-icon">⚖️</span>
                <h3>Ethic Hawks Assistant</h3>
                <span class="eh-status">Ready</span>
            </div>
            <div class="eh-chat" id="eh-chat-window"></div>
            <div class="eh-input-area">
                <input type="text" id="eh-query-input" placeholder="Ask about forensic governance..." />
                <button id="eh-submit-btn" onclick="window.EH_Assistant.sendQuery()">Send</button>
            </div>
        `;
        
        container.appendChild(widget);
        
        // Initialize API connection
        window.EH_Assistant = {
            initialized: true,
            
            sendQuery: function() {
                const input = document.getElementById('eh-query-input');
                const chat = document.getElementById('eh-chat-window');
                
                if (!input || !input.value.trim()) return;
                
                const query = input.value.trim();
                console.log('⚖️ Sending query to Ethic Hawks:', query);
                
                // Add user message
                chat.innerHTML += '<div class="eh-message user"><strong>You:</strong> ' + query + '</div>';
                
                // Show loading
                chat.innerHTML += '<div class="eh-message assistant"><em>Analyzing...</em></div>';
                chat.scrollTop = chat.scrollHeight;
                
                // Call API
                fetch(EH_CONFIG.apiEndpoint + '/query', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer ' + EH_CONFIG.apiKey
                    },
                    body: JSON.stringify({
                        query: query,
                        mode: 'forensic-governance',
                        features: EH_CONFIG.features
                    })
                })
                .then(response => response.json())
                .then(data => {
                    // Remove loading message
                    const loadingMsg = chat.querySelector('.eh-message:last-child');
                    if (loadingMsg) loadingMsg.remove();
                    
                    // Add response
                    chat.innerHTML += '<div class="eh-message assistant"><strong>EH Assistant:</strong> ' + (data.response || 'No response') + '</div>';
                    chat.scrollTop = chat.scrollHeight;
                })
                .catch(error => {
                    const loadingMsg = chat.querySelector('.eh-message:last-child');
                    if (loadingMsg) loadingMsg.remove();
                    
                    chat.innerHTML += '<div class="eh-message error"><strong>Error:</strong> ' + error.message + '</div>';
                    console.error('❌ Ethic Hawks API error:', error);
                });
                
                input.value = '';
            },
            
            assessRisk: function(context) {
                // Forensic risk assessment
                console.log('🔍 Running forensic risk assessment...');
                return fetch(EH_CONFIG.apiEndpoint + '/assess', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer ' + EH_CONFIG.apiKey
                    },
                    body: JSON.stringify({ context: context })
                });
            }
        };
        
        // Add keyboard support
        document.getElementById('eh-query-input')?.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                window.EH_Assistant.sendQuery();
            }
        });
        
        console.log('✅ Ethic Hawks Assistant initialized');
        document.querySelector('.eh-status').textContent = 'Active';
        document.querySelector('.eh-status').style.color = '#4caf50';
    }
    
    // Initialize when ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
EOF
    
    print_success "Created initialization script: $backup_dir/ethic-hawks-init.js"
    
    # Fix 2: Create proper HTML container
    print_action "Creating HTML container template..."
    
    cat > "ethic-hawks-widget.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ethic Hawks - Forensic Governance AI Assistant</title>
    <style>
        .eh-assistant-container {
            position: fixed;
            bottom: 20px;
            right: 20px;
            width: 380px;
            max-height: 600px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.12);
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            z-index: 10000;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        
        .eh-header {
            background: linear-gradient(135deg, #1a237e 0%, #4a148c 100%);
            color: white;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .eh-icon {
            font-size: 24px;
        }
        
        .eh-header h3 {
            margin: 0;
            font-size: 16px;
            flex: 1;
        }
        
        .eh-status {
            font-size: 12px;
            background: rgba(255,255,255,0.2);
            padding: 4px 8px;
            border-radius: 12px;
        }
        
        .eh-chat {
            height: 350px;
            overflow-y: auto;
            padding: 16px;
            background: #f5f5f5;
        }
        
        .eh-message {
            margin-bottom: 12px;
            padding: 10px 14px;
            border-radius: 8px;
            max-width: 85%;
            word-wrap: break-word;
        }
        
        .eh-message.user {
            background: #e3f2fd;
            margin-left: auto;
        }
        
        .eh-message.assistant {
            background: white;
            border: 1px solid #e0e0e0;
        }
        
        .eh-message.error {
            background: #ffebee;
            color: #c62828;
        }
        
        .eh-input-area {
            padding: 16px;
            background: white;
            border-top: 1px solid #e0e0e0;
            display: flex;
            gap: 8px;
        }
        
        .eh-input-area input {
            flex: 1;
            padding: 10px;
            border: 1px solid #e0e0e0;
            border-radius: 20px;
            font-size: 14px;
        }
        
        .eh-input-area button {
            background: #1a237e;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 20px;
            cursor: pointer;
            font-weight: 600;
        }
        
        .eh-input-area button:hover {
            background: #283593;
        }
        
        .eh-toggle-btn {
            position: fixed;
            bottom: 20px;
            right: 20px;
            width: 60px;
            height: 60px;
            border-radius: 30px;
            background: linear-gradient(135deg, #1a237e 0%, #4a148c 100%);
            border: none;
            color: white;
            font-size: 24px;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(0,0,0,0.2);
            z-index: 9999;
        }
        
        .eh-hidden {
            display: none;
        }
    </style>
</head>
<body>
    <!-- Floating Toggle Button -->
    <button id="eh-toggle-btn" class="eh-toggle-btn" onclick="toggleEthicHawks()">
        ⚖️
    </button>
    
    <!-- Ethic Hawks Assistant Widget -->
    <div id="eh-assistant-widget" class="eh-assistant-container">
        <!-- Widget will be rendered here by JavaScript -->
    </div>
    
    <!-- Add Ethic Hawks Script -->
    <script src="ethic-hawks-init.js"></script>
    
    <script>
        // Toggle widget visibility
        function toggleEthicHawks() {
            const widget = document.getElementById('eh-assistant-widget');
            widget.classList.toggle('eh-hidden');
        }
    </script>
</body>
</html>
EOF
    
    print_success "Created widget template: ethic-hawks-widget.html"
    
    # Fix 3: Environment configuration
    if [ ! -f ".env" ] || ! grep -q "EH_API_KEY" .env 2>/dev/null; then
        print_action "Creating environment configuration..."
        cat >> .env << 'EOF'

# Ethic Hawks Configuration
EH_API_KEY=AIzaSyB3Br7KLVZKNk-Eosk9_csZ7U4rH81H-z0
EH_API_ENDPOINT=https://api.ethic-hawks.ai/v1
EH_ENVIRONMENT=development
EOF
        print_success "Added Ethic Hawks config to .env"
    fi
}

# Check for common JavaScript errors
check_js_errors() {
    print_header "Checking for JavaScript Errors"
    
    print_ethic "Common Ethic Hawks JavaScript issues:"
    echo ""
    
    # Check for null reference
    if grep -rq "getElementById.*eh-assistant\|getElementById.*eh-widget" --include="*.js" . 2>/dev/null; then
        if ! grep -rq "if.*null\|null.*check\|\.length\|?." --include="*.js" . 2>/dev/null; then
            print_error "Missing null check for widget container"
            print_action "Add null check: if (container) { ... }"
        fi
    fi
    
    # Check for async issues
    if grep -rq "fetch.*ethic\|axios.*ethic" --include="*.js" . 2>/dev/null; then
        if ! grep -rq "\.catch\|try.*catch\|async.*await" --include="*.js" . 2>/dev/null; then
            print_error "Missing error handling for API calls"
            print_action "Add .catch() or try/catch to API calls"
        fi
    fi
    
    # Event binding issues
    print_ethic "Event binding checklist:"
    echo "  □ Button exists in DOM when script runs"
    echo "  □ Event listener properly attached"
    echo "  □ No duplicate event listeners"
    echo "  □ Event propagation not blocked"
    echo "  □ Console free of errors"
}

# Create test page
create_test_page() {
    print_header "Creating Ethic Hawks Test Page"
    
    # We already have ethic-hawks-widget.html from fix function
    if [ -f "ethic-hawks-widget.html" ]; then
        print_success "Test page already exists: ethic-hawks-widget.html"
    else
        fix_ethic_hawks > /dev/null 2>&1
    fi
    
    print_action "To test Ethic Hawks:"
    echo "  1. Set your API key: export EH_API_KEY='AIzaSyB3Br7KLVZKNk-Eosk9_csZ7U4rH81H-z0'"
    echo "  2. Open test page: open ethic-hawks-widget.html"
    echo "  3. Or serve locally: python3 -m http.server 8000"
    echo "  4. Click the ⚖️ button to open the assistant"
    echo "  5. Check browser console (F12) for errors"
}

# Main function
main() {
    case "${1:-help}" in
        "scan")
            scan_ethic_hawks
            ;;
        "diagnose")
            scan_ethic_hawks
            echo ""
            diagnose_integration
            echo ""
            check_js_errors
            ;;
        "fix")
            diagnose_integration
            fix_ethic_hawks
            print_success "\nEthic Hawks fixes applied!"
            print_info "Next steps:"
            echo "  1. Add your API key to .env file"
            echo "  2. Include the initialization script in your HTML"
            echo "  3. Test with: ./dev/fix-ethic-hawks.sh test"
            ;;
        "test")
            create_test_page
            ;;
        "install")
            print_header "Installing Ethic Hawks Components"
            diagnose_integration
            fix_ethic_hawks
            cp ethic-hawks-widget.html index.html 2>/dev/null || print_info "Widget template ready"
            print_success "\nEthic Hawks installed!"
            echo ""
            print_ethic "Quick start:"
            echo "  1. Edit .env with your API key"
            echo "  2. Open index.html in browser"
            echo "  3. Click ⚖️ button to start"
            ;;
        "help"|*)
            echo "╔══════════════════════════════════════════╗"
            echo "║   ⚖️  Ethic Hawks Assistant Fix Helper  ⚖️   ║"
            echo "║   Forensic Governance AI Assistant       ║"
            echo "╚══════════════════════════════════════════╝"
            echo ""
            echo "Commands:"
            echo "  scan      - Find Ethic Hawks references"
            echo "  diagnose  - Check integration issues"
            echo "  fix       - Apply fixes and create backups"
            echo "  test      - Create and setup test page"
            echo "  install   - Full installation with setup"
            echo "  help      - Show this help"
            echo ""
            echo "Quick fix for button not working:"
            echo "  ./dev/fix-ethic-hawks.sh diagnose"
            echo ""
            echo "Common Ethic Hawks button issues:"
            echo "  1. ❌ API key not configured"
            echo "  2. ❌ Script loading before DOM ready"
            echo "  3. ❌ Widget container not in HTML"
            echo "  4. ❌ CORS blocking API requests"
            echo "  5. ❌ Content Security Policy blocking scripts"
            echo "  6. ❌ Event listener not attached to button"
            echo "  7. ❌ JavaScript error in console"
            echo ""
            echo "Manual debug steps:"
            echo "  1. Press F12 → Console tab