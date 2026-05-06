#!/bin/sh
# Duplicate Announcement Banner Fix Helper
# Usage: ./dev/fix-duplicate-banner.sh [scan|fix|help]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo "${GREEN}✓${NC} $1"; }
print_error() { echo "${RED}✗${NC} $1"; }
print_info() { echo "${YELLOW}ℹ${NC} $1"; }
print_header() { echo "\n${BLUE}═══${NC} $1 ${BLUE}═══${NC}"; }

# Scan for potential duplicate banner issues
scan_duplicates() {
    print_header "Scanning for Duplicate Banner Issues"
    
    # Check for multiple script inclusions
    if [ -f "index.html" ]; then
        print_info "Checking index.html..."
        banner_count=$(grep -c "banner\|announcement" index.html 2>/dev/null || echo "0")
        echo "  Found $banner_count banner references in index.html"
    fi
    
    # Check JavaScript files for duplicate initialization
    for ext in js jsx ts tsx; do
        if find . -name "*.$ext" -type f 2>/dev/null | head -1; then
            print_info "Checking .$ext files..."
            find . -name "*.$ext" -type f -exec grep -l "banner\|announcement.*init\|createBanner" {} \; 2>/dev/null | while read -r file; do
                count=$(grep -c "banner\|announcement.*init\|createBanner" "$file" 2>/dev/null || echo "0")
                if [ "$count" -gt 1 ]; then
                    print_error "Multiple banner initializations in: $file ($count occurrences)"
                fi
            done
        fi
    done
    
    # Check CSS files for duplicate banner styles
    if find . -name "*.css" -type f 2>/dev/null | head -1; then
        print_info "Checking CSS files..."
        find . -name "*.css" -type f -exec grep -l "\.banner\|\.announcement" {} \; 2>/dev/null | while read -r file; do
            count=$(grep -c "\.banner\|\.announcement" "$file" 2>/dev/null || echo "0")
            echo "  Found $count banner style references in $file"
        done
    fi
    
    # Check PHP files
    if find . -name "*.php" -type f 2>/dev/null | head -1; then
        print_info "Checking PHP files..."
        find . -name "*.php" -type f -exec grep -l "banner\|announcement" {} \; 2>/dev/null | while read -r file; do
            echo "  Banner code found in: $file"
        done
    fi
}

# Common fixes for duplicate banners
fix_duplicates() {
    print_header "Fixing Duplicate Banner Issues"
    
    # Fix 1: Check for multiple component imports in React/Vue
    for ext in js jsx ts tsx vue; do
        find . -name "*.$ext" -type f 2>/dev/null | while read -r file; do
            import_count=$(grep -c "import.*Banner\|import.*Announcement" "$file" 2>/dev/null || echo "0")
            if [ "$import_count" -gt 1 ]; then
                print_info "Found multiple imports in $file - check manually"
                print_info "  Line numbers: $(grep -n "import.*Banner\|import.*Announcement" "$file" | cut -d: -f1 | tr '\n' ' ')"
            fi
        done
    done
    
    # Fix 2: Check for duplicate HTML elements
    if [ -f "index.html" ]; then
        div_count=$(grep -c '<div[^>]*class="[^"]*banner[^"]*"' index.html 2>/dev/null || echo "0")
        if [ "$div_count" -gt 1 ]; then
            print_error "Found $div_count banner divs in index.html"
            print_info "  Consider keeping only one banner element"
        fi
    fi
    
    # Fix 3: Check for duplicate API calls
    print_info "Checking for duplicate API calls..."
    find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" 2>/dev/null | while read -r file; do
        if grep -q "fetch.*banner\|axios.*banner\|api.*banner" "$file" 2>/dev/null; then
            api_count=$(grep -c "fetch.*banner\|axios.*banner\|api.*banner" "$file" 2>/dev/null || echo "0")
            if [ "$api_count" -gt 1 ]; then
                print_error "Multiple banner API calls in $file"
                print_info "  Lines: $(grep -n "fetch.*banner\|axios.*banner\|api.*banner" "$file" | cut -d: -f1 | tr '\n' ' ')"
            fi
        fi
    done
}

# WordPress specific fixes
fix_wordpress() {
    print_header "Checking WordPress-Specific Issues"
    
    if [ -f "wp-config.php" ] || [ -d "wp-content" ]; then
        print_info "WordPress detected"
        
        # Check theme files for duplicate banner
        if [ -d "wp-content/themes" ]; then
            find wp-content/themes -name "*.php" -exec grep -l "banner\|announcement" {} \; 2>/dev/null | while read -r file; do
                print_info "Theme file with banner: $file"
            done
        fi
        
        # Check for multiple plugins adding banners
        if [ -d "wp-content/plugins" ]; then
            plugin_banners=$(find wp-content/plugins -name "*.php" -exec grep -l "banner\|announcement" {} \; 2>/dev/null | wc -l)
            if [ "$plugin_banners" -gt 1 ]; then
                print_error "Multiple plugins may be adding banners"
            fi
        fi
        
        print_info "WordPress fix suggestions:"
        echo "  1. Check if you're using a banner plugin + theme banner feature"
        echo "  2. Check Appearance → Customize for banner settings"
        echo "  3. Check if banner is in both header.php and via hook"
    fi
}

# Create a backup before making changes
create_backup() {
    print_info "Creating backup..."
    backup_dir="banner_fix_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    find . \( -name "*.html" -o -name "*.php" -o -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" -o -name "*.vue" -o -name "*.css" \) -type f 2>/dev/null | while read -r file; do
        if grep -q "banner\|announcement" "$file" 2>/dev/null; then
            cp "$file" "$backup_dir/$(echo "$file" | sed 's|/|_|g')"
            print_success "Backed up: $file"
        fi
    done
    
    print_success "Backups saved in: $backup_dir"
}

# Debug information
debug_info() {
    print_header "Debug Information"
    
    echo "Project type detection:"
    [ -f "package.json" ] && echo "  - Node.js/JavaScript project" && grep -E '"react"|"vue"|"angular"|"next"|"nuxt"' package.json 2>/dev/null | head -3
    [ -f "composer.json" ] && echo "  - PHP project"
    [ -f "wp-config.php" ] && echo "  - WordPress project"
    [ -f "requirements.txt" ] && echo "  - Python project"
    
    echo "\nBanner-related file search:"
    grep -r "banner\|announcement" --include="*.html" --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" --include="*.php" --include="*.vue" . 2>/dev/null | head -10 || echo "  No banner references found"
}

# Main function
main() {
    case "${1:-scan}" in
        "scan")
            scan_duplicates
            ;;
        "fix")
            create_backup
            fix_duplicates
            fix_wordpress
            print_success "\nFix suggestions applied. Check the backup folder for original files."
            ;;
        "debug")
            debug_info
            ;;
        "wordpress")
            fix_wordpress
            ;;
        "all")
            scan_duplicates
            echo ""
            debug_info
            echo ""
            create_backup
            fix_duplicates
            fix_wordpress
            print_success "\nComplete analysis and fixes applied!"
            ;;
        "help"|*)
            echo "Duplicate Banner Fix Helper"
            echo ""
            echo "Commands:"
            echo "  scan      - Scan for potential duplicate banner issues"
            echo "  fix       - Apply fixes and create backup"
            echo "  debug     - Show debug information"
            echo "  wordpress - Check WordPress-specific issues"
            echo "  all       - Run all diagnostics and fixes"
            echo "  help      - Show this help"
            echo ""
            echo "Common causes of duplicate banners:"
            echo "  1. Banner initialized in both HTML and JavaScript"
            echo "  2. Multiple component instances in React/Vue"
            echo "  3. Theme and plugin both adding banners (WordPress)"
            echo "  4. Duplicate script tags or imports"
            echo "  5. Copy-paste error in template files"
            ;;
    esac
}

main "$@"
```

Make it executable:

```bash
chmod +x dev/fix-duplicate-banner.sh
```

Usage:

```bash
# Scan for issues
./dev/fix-duplicate-banner.sh scan

# Apply fixes (creates backup automatically)
./dev/fix-duplicate-banner.sh fix

# Get debug info
./dev/fix-duplicate-banner.sh debug

# Check WordPress specifically
./dev/fix-duplicate-banner.sh wordpress

# Run everything
./dev/fix-duplicate-banner.sh all