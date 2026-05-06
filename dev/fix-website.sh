set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
    echo "${GREEN}✓${NC} $1"
}

print_error() {
    echo "${RED}✗${NC} $1"
}

print_info() {
    echo "${YELLOW}ℹ${NC} $1"
}

# Check if running in dev container
check_environment() {
    if [ ! -f "/.dockerenv" ] && [ ! -f "/run/.containerenv" ]; then
        print_error "This script should be run inside the dev container"
        exit 1
    fi
    print_success "Running in dev container"
}

# Fix permissions
fix_permissions() {
    print_info "Fixing file permissions..."
    
    # Fix ownership for workspace files
    if [ -d "/workspace" ]; then
        sudo chown -R vscode:vscode /workspace 2>/dev/null || true
        print_success "Fixed workspace permissions"
    fi
    
    # Fix common web directories permissions
    for dir in "public" "static" "assets" "uploads" "storage"; do
        if [ -d "$dir" ]; then
            chmod -R 755 "$dir" 2>/dev/null || true
            print_success "Fixed $dir permissions"
        fi
    done
}

# Fix common web issues
fix_web_config() {
    print_info "Checking web configuration..."
    
    # Check for common config files
    if [ -f "package.json" ]; then
        print_info "Node.js project detected"
        # Fix node_modules if needed
        if [ -f "package-lock.json" ] || [ -f "yarn.lock" ] || [ -f "pnpm-lock.yaml" ]; then
            if [ ! -d "node_modules" ]; then
                print_info "Installing dependencies..."
                npm install || yarn install || pnpm install
                print_success "Dependencies installed"
            fi
        fi
    fi
    
    if [ -f "composer.json" ]; then
        print_info "PHP project detected"
        if [ ! -d "vendor" ]; then
            print_info "Installing Composer dependencies..."
            composer install
            print_success "Composer dependencies installed"
        fi
    fi
    
    if [ -f "requirements.txt" ]; then
        print_info "Python project detected"
        pip install -r requirements.txt
        print_success "Python dependencies installed"
    fi
}

# Clear caches
clear_caches() {
    print_info "Clearing caches..."
    
    # Clear npm/yarn cache if present
    if command -v npm >/dev/null 2>&1; then
        npm cache clean --force 2>/dev/null || true
        print_success "npm cache cleared"
    fi
    
    # Clear composer cache if present
    if command -v composer >/dev/null 2>&1; then
        composer clear-cache 2>/dev/null || true
        print_success "Composer cache cleared"
    fi
    
    # Clear Laravel caches if present
    if [ -f "artisan" ]; then
        php artisan cache:clear 2>/dev/null || true
        php artisan config:clear 2>/dev/null || true
        php artisan view:clear 2>/dev/null || true
        php artisan route:clear 2>/dev/null || true
        print_success "Laravel caches cleared"
    fi
    
    # Clear Symfony cache if present
    if [ -f "bin/console" ] && [ -d "var/cache" ]; then
        php bin/console cache:clear 2>/dev/null || true
        print_success "Symfony cache cleared"
    fi
}

# Run dev server
start_dev_server() {
    print_info "Starting development server..."
    
    if [ -f "package.json" ]; then
        if grep -q '"dev"' package.json; then
            npm run dev
        elif grep -q '"start"' package.json; then
            npm start
        else
            print_error "No dev or start script found in package.json"
        fi
    elif [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
        docker-compose up
    else
        print_error "Could not determine how to start the dev server"
    fi
}

# Check and fix SSL/HTTPS issues
fix_ssl() {
    print_info "Checking SSL configuration..."
    
    if [ ! -f "localhost.key" ] || [ ! -f "localhost.crt" ]; then
        print_info "Generating self-signed SSL certificates..."
        openssl req -x509 -newkey rsa:4096 -keyout localhost.key -out localhost.crt \
            -days 365 -nodes -subj "/CN=localhost" 2>/dev/null
        print_success "SSL certificates generated"
    fi
}

# Main function
main() {
    case "${1:-help}" in
        "fix")
            echo "🔧 Fixing website issues..."
            check_environment
            fix_permissions
            fix_web_config
            clear_caches
            print_success "All fixes applied! Your website should be working now."
            ;;
        "permissions")
            check_environment
            fix_permissions
            ;;
        "cache")
            clear_caches
            ;;
        "deps")
            check_environment
            fix_web_config
            ;;
        "ssl")
            fix_ssl
            ;;
        "start"|"dev")
            start_dev_server
            ;;
        "check")
            check_environment
            print_info "Environment check complete"
            ;;
        "help"|*)
            echo "Website Fix Helper - Available commands:"
            echo "  fix          - Run all fixes (permissions, deps, cache)"
            echo "  permissions  - Fix file permissions only"
            echo "  cache        - Clear all caches"
            echo "  deps         - Install/update dependencies"
            echo "  ssl          - Generate SSL certificates"
            echo "  start/dev    - Start development server"
            echo "  check        - Check environment"
            echo "  help         - Show this help message"
            ;;
    esac
}

# Run main function
main "$@"
```

Make it executable:

After creating the file, make it executable:

```bash
chmod +x dev/fix-website.sh
```

Usage examples:

```bash
# Fix everything
./dev/fix-website.sh fix

# Fix permissions only
./dev/fix-website.sh permissions

# Clear caches
./dev/fix-website.sh cache

# Start dev server
./dev/fix-website.sh dev

# Show help
./dev/fix-website.sh help
```

Optional: Add to .bashrc for easy access

Add this to your container's .bashrc:

```bash
alias fix-site='./dev/fix-website.sh fix'
alias fix-perms='./dev/fix-website.sh permissions'
alias fix-cache='./dev/fix-website.sh cache'
alias fix-dev='./dev/fix-website.sh dev'
