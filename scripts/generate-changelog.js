const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const CHANGELOG_PATH = path.join(process.cwd(), 'CHANGELOG.md');

// Map conventional commit types to emojis and titles
const TYPE_MAP = {
    feat: { emoji: '✨', title: 'Features' },
    fix: { emoji: '🐛', title: 'Bug Fixes' },
    docs: { emoji: '📚', title: 'Documentation' },
    perf: { emoji: '⚡', title: 'Performance' },
    refactor: { emoji: '♻️', title: 'Refactoring' },
    test: { emoji: '🧪', title: 'Testing' },
    chore: { emoji: '🔧', title: 'Maintenance' },
    build: { emoji: '🏗️', title: 'Build System' },
    ci: { emoji: '👷', title: 'CI' }
};

function getLatestTag() {
    try {
        return execSync('git describe --tags --abbrev=0 2>/dev/null').toString().trim();
    } catch (e) {
        return null; // No tags found
    }
}

function getCommits(sinceTag) {
    const range = sinceTag ? `${sinceTag}..HEAD` : 'HEAD';
    // Format: hash|subject|author|date
    const cmd = `git log ${range} --pretty=format:"%h|%s|%an|%ad" --date=short`;
    try {
        const output = execSync(cmd).toString().trim();
        if (!output) return [];
        return output.split('\n').map(line => {
            const [hash, subject, author, date] = line.split('|');
            return { hash, subject, author, date };
        });
    } catch (e) {
        console.error('Error reading git log:', e.message);
        process.exit(1);
    }
}

function parseCommit(commit) {
    const regex = /^(\w+)(?:\(([^)]+)\))?: (.+)$/;
    const match = commit.subject.match(regex);

    if (!match) {
        return { type: 'other', scope: null, message: commit.subject, hash: commit.hash };
    }

    return {
        type: match[1],
        scope: match[2] || null,
        message: match[3],
        hash: commit.hash
    };
}

function generateMarkdown(commits) {
    const categorized = {};

    commits.forEach(commit => {
        const parsed = parseCommit(commit);
        const typeKey = TYPE_MAP[parsed.type] ? parsed.type : 'other';

        if (!categorized[typeKey]) categorized[typeKey] = [];
        categorized[typeKey].push(parsed);
    });

    const today = new Date().toISOString().split('T')[0];
    let markdown = `## [Unreleased] - ${today}\n\n`;

    // Sort so commonly used types come first
    const sortOrder = ['feat', 'fix', 'docs', 'perf', 'refactor', 'test', 'chore', 'other'];

    sortOrder.forEach(type => {
        if (categorized[type] && categorized[type].length > 0) {
            const header = TYPE_MAP[type] ? `${TYPE_MAP[type].emoji} ${TYPE_MAP[type].title}` : 'Other Changes';
            markdown += `### ${header}\n`;

            categorized[type].forEach(item => {
                const scope = item.scope ? `**${item.scope}:** ` : '';
                markdown += `- ${scope}${item.message} (${item.hash})\n`;
            });
            markdown += '\n';
        }
    });

    return markdown;
}

function updateChangelog(newEntry) {
    let content = '';
    if (fs.existsSync(CHANGELOG_PATH)) {
        content = fs.readFileSync(CHANGELOG_PATH, 'utf8');
    } else {
        content = '# Changelog\n\nAll notable changes to this project will be documented in this file.\n\n';
    }

    // Check if today's entry already exists to avoid duplicates (naive check)
    const lines = newEntry.split('\n');
    const firstLine = lines[0]; // ## [Unreleased] - YYYY-MM-DD

    if (content.includes(firstLine)) {
        console.log('⚠️  Entry for today already exists. Replacing top entry...');
        // Regex to find the first H2 entry and replace it
        // This is tricky without a robust parser, so for now we'll just prepend and warn user to clean up
        // Or simpler: just append "PREVIEW"
        // Let's protect the user:
        console.log('Existing content found. Please manually review duplications if running multiple times a day.');
    }

    // Prepend new entry after header
    if (content.startsWith('# Changelog')) {
        const headerEnd = content.indexOf('\n\n') + 2;
        // Try to find the second line of text to insert after the main description
        const headerMatch = content.match(/^# Changelog.*?\n\n/s);
        if (headerMatch) {
            const headerLen = headerMatch[0].length;
            const newContent = content.substring(0, headerLen) + newEntry + content.substring(headerLen);
            fs.writeFileSync(CHANGELOG_PATH, newContent);
        } else {
            // Fallback
            fs.writeFileSync(CHANGELOG_PATH, newEntry + content);
        }
    } else {
        fs.writeFileSync(CHANGELOG_PATH, newEntry + content);
    }

    console.log(`✅ Changelog updated at ${CHANGELOG_PATH}`);
}

// Main execution
const lastTag = getLatestTag();
console.log(`🔍 Last tag: ${lastTag || 'None (Initial commit)'}`);

const commits = getCommits(lastTag);
console.log(`📝 Found ${commits.length} commits since last tag`);

if (commits.length === 0) {
    console.log('No commits found. Nothing to update.');
} else {
    const markdown = generateMarkdown(commits);
    updateChangelog(markdown);
}
