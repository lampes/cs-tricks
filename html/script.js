// UI State
let isVisible = true;
let currentTrickActive = false;
let trickStartTime = 0;
let trickTimer = null;
let config = {};

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    console.log('CS-Tricks UI loaded');
});

// Listen for messages from FiveM
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.type) {
        case 'init':
            config = data.config;
            initializeUI();
            break;
            
        case 'toggleUI':
            toggleUI(data.visible);
            break;
            
        case 'updateScore':
            updateScore(data.score, data.totalScore, data.sessionScore);
            break;
            
        case 'showTrick':
            showTrickNotification(data);
            break;
            
        case 'showCombo':
            showCombo(data.comboCount);
            break;
            
        case 'showPerfect':
            showPerfectAnimation(data.trickType, data.bonus);
            break;
            
        case 'resetStats':
            resetStats();
            break;
    }
});

// Initialize UI with config
function initializeUI() {
    const scoreContainer = document.getElementById('score-container');
    const comboContainer = document.getElementById('combo-container');
    
    if (!config.showScore) {
        scoreContainer.style.display = 'none';
    }
    
    if (!config.showCombo) {
        comboContainer.style.display = 'none';
    }
    
    // Position adjustments
    if (config.position) {
        scoreContainer.style.right = `${100 - config.position.x}%`;
        scoreContainer.style.top = `${config.position.y}%`;
    }
}

// Toggle UI visibility
function toggleUI(visible) {
    isVisible = visible;
    const container = document.getElementById('main-container');
    container.style.display = visible ? 'block' : 'none';
}

// Update score display
function updateScore(score, totalScore, sessionScore) {
    if (!isVisible || !config.showScore) return;
    
    const scoreValue = document.getElementById('score-value');
    const sessionValue = document.getElementById('session-value');
    
    // Animate score change
    if (score > 0) {
        animateScoreChange(scoreValue, totalScore);
    } else {
        scoreValue.textContent = formatNumber(totalScore);
    }
    
    sessionValue.textContent = formatNumber(sessionScore);
}

// Animate score change
function animateScoreChange(element, newValue) {
    element.classList.add('score-animation');
    element.textContent = formatNumber(newValue);
    
    setTimeout(() => {
        element.classList.remove('score-animation');
    }, 500);
}

// Show trick notification
function showTrickNotification(data) {
    if (!isVisible || !config.showTrickName) return;
    
    const container = document.getElementById('trick-notifications');
    const notification = document.createElement('div');
    
    notification.className = `trick-notification ${data.status}`;
    if (data.trickType.includes('flip')) {
        notification.classList.add('flip');
    }
    
    let title = '';
    let details = '';
    
    if (data.status === 'started') {
        title = `${capitalizeFirst(data.trickType)} Started!`;
        details = 'Keep it up!';
        
        // Show current trick display
        showCurrentTrick(data.trickType);
    } else if (data.status === 'completed') {
        title = `${capitalizeFirst(data.trickType)} Completed!`;
        if (data.duration) {
            const duration = (data.duration / 1000).toFixed(1);
            details = `+${data.score} points (${duration}s)`;
        } else {
            details = `+${data.score} points`;
        }
        
        // Hide current trick display
        hideCurrentTrick();
    }
    
    notification.innerHTML = `
        <div class="notification-title">${title}</div>
        <div class="notification-details">${details}</div>
    `;
    
    container.appendChild(notification);
    
    // Remove notification after animation
    setTimeout(() => {
        if (notification.parentNode) {
            notification.parentNode.removeChild(notification);
        }
    }, 3000);
}

// Show current trick display
function showCurrentTrick(trickType) {
    const currentTrick = document.getElementById('current-trick');
    const trickName = document.getElementById('trick-name');
    const trickTimerEl = document.getElementById('trick-timer');
    
    trickName.textContent = trickType.toUpperCase();
    currentTrick.classList.remove('hidden');
    
    currentTrickActive = true;
    trickStartTime = Date.now();
    
    // Start timer
    if (trickTimer) clearInterval(trickTimer);
    trickTimer = setInterval(() => {
        const elapsed = (Date.now() - trickStartTime) / 1000;
        trickTimerEl.textContent = `${elapsed.toFixed(1)}s`;
    }, 100);
}

// Hide current trick display
function hideCurrentTrick() {
    const currentTrick = document.getElementById('current-trick');
    currentTrick.classList.add('hidden');
    
    currentTrickActive = false;
    if (trickTimer) {
        clearInterval(trickTimer);
        trickTimer = null;
    }
}

// Show combo display
function showCombo(comboCount) {
    if (!isVisible || !config.showCombo) return;
    
    const comboContainer = document.getElementById('combo-container');
    const comboValue = document.getElementById('combo-value');
    
    comboValue.textContent = `x${comboCount}`;
    comboContainer.classList.remove('hidden');
    
    // Auto-hide after 3 seconds
    setTimeout(() => {
        comboContainer.classList.add('hidden');
    }, 3000);
}

// Show perfect trick animation
function showPerfectAnimation(trickType, bonus) {
    if (!isVisible) return;
    
    const perfectAnimation = document.getElementById('perfect-animation');
    const perfectBonus = document.getElementById('perfect-bonus');
    
    perfectBonus.textContent = `+${bonus}`;
    perfectAnimation.classList.remove('hidden');
    
    // Hide after animation
    setTimeout(() => {
        perfectAnimation.classList.add('hidden');
    }, 2000);
}

// Reset stats display
function resetStats() {
    updateScore(0, 0, 0);
    
    // Clear notifications
    const container = document.getElementById('trick-notifications');
    container.innerHTML = '';
    
    // Hide current trick
    hideCurrentTrick();
    
    // Hide combo
    const comboContainer = document.getElementById('combo-container');
    comboContainer.classList.add('hidden');
}

// Utility functions
function formatNumber(num) {
    return num.toLocaleString();
}

function capitalizeFirst(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}

// Close UI callback
function closeUI() {
    fetch('http://cs-tricks/closeUI', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

// Event listeners
document.getElementById('close-stats')?.addEventListener('click', function() {
    document.getElementById('stats-panel').classList.add('hidden');
});

// Escape key to close UI
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeUI();
    }
});

// Add CSS animation class
const style = document.createElement('style');
style.textContent = `
    .score-animation {
        animation: scoreGlow 0.5s ease-out;
    }
    
    @keyframes scoreGlow {
        0% { 
            color: #00ff88; 
            text-shadow: 0 0 10px rgba(0, 255, 136, 0.5);
        }
        50% { 
            color: #00ffff; 
            text-shadow: 0 0 20px rgba(0, 255, 255, 0.8);
            transform: scale(1.1);
        }
        100% { 
            color: #00ff88; 
            text-shadow: 0 0 10px rgba(0, 255, 136, 0.5);
            transform: scale(1);
        }
    }
`;
document.head.appendChild(style);