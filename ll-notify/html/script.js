// Notification system

let config = {
    position: {
        horizontal: 'right',
        vertical: 'top'
    },
    style: {
        maxStack: 5,
        spacing: 10,
        animationSpeed: 300
    },
    sounds: {
        enabled: true,
        volume: 0.3
    }
};

let notifications = [];
let notificationId = 0;
let progressInterval = null;

// DOM elements
const container = document.getElementById('notification-container');
const persistentContainer = document.getElementById('persistent-container');
const progressContainer = document.getElementById('progress-container');
const progressBar = document.getElementById('progress-bar');
const progressLabel = document.getElementById('progress-label');
const progressPercentage = document.getElementById('progress-percentage');

// Message listener
window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch(data.action) {
        case 'setConfig':
            setConfig(data.data);
            break;
        case 'notify':
            showNotification(data.data);
            break;
        case 'persistent':
            showPersistent(data.data);
            break;
        case 'removePersistent':
            removePersistent(data.data.id);
            break;
        case 'progress':
            showProgress(data.data);
            break;
        case 'cancelProgress':
            hideProgress();
            break;
        case 'completeProgress':
            hideProgress();
            break;
        case 'clearAll':
            clearAllNotifications();
            break;
        case 'playSound':
            playSound(data.data.sound, data.data.volume);
            break;
    }
});

// Config beállítása
function setConfig(cfg) {
    config = { ...config, ...cfg };
    updateContainerPosition();
}

// Container pozíció beállítása
function updateContainerPosition() {
    const pos = config.position;
    container.className = '';
    container.classList.add(`${pos.vertical}-${pos.horizontal}`);
}

// Notification megjelenítése
function showNotification(data) {
    // Stack limit ellenőrzés
    if (notifications.length >= config.style.maxStack) {
        // Legrégebbi törlése
        const oldest = notifications.shift();
        removeNotification(oldest.id);
    }
    
    const id = ++notificationId;
    const notification = createNotificationElement(data, id);
    
    // Hozzáadás a DOM-hoz
    container.appendChild(notification);
    
    // Notification objektum tárolása
    notifications.push({
        id: id,
        element: notification,
        timeout: null
    });
    
    // Hang lejátszása
    if (data.sound && config.sounds.enabled) {
        playSound(data.sound, config.sounds.volume);
    }
    
    // Auto-close timer
    if (data.duration > 0) {
        const notifObj = notifications.find(n => n.id === id);
        notifObj.timeout = setTimeout(() => {
            closeNotification(id);
        }, data.duration);
        
        // Progress bar animáció
        const progressBar = notification.querySelector('.notification-progress-bar');
        if (progressBar) {
            progressBar.style.transition = `width ${data.duration}ms linear`;
            setTimeout(() => {
                progressBar.style.width = '0%';
            }, 10);
        }
    }
}

// Notification elem létrehozása
function createNotificationElement(data, id) {
    const notif = document.createElement('div');
    notif.className = `notification ${data.type}`;
    notif.dataset.id = id;
    
    // Pulse vagy shake animáció
    if (data.pulse) notif.classList.add('pulse');
    if (data.shake) notif.classList.add('shake');
    
    // Icon
    const icon = document.createElement('div');
    icon.className = 'notification-icon';
    icon.textContent = data.icon || '📢';
    notif.appendChild(icon);
    
    // Content
    const content = document.createElement('div');
    content.className = 'notification-content';
    
    if (data.title) {
        const title = document.createElement('div');
        title.className = 'notification-title';
        title.textContent = data.title;
        content.appendChild(title);
    }
    
    const message = document.createElement('div');
    message.className = 'notification-message';
    message.textContent = data.message;
    content.appendChild(message);
    
    // Progress bar
    if (data.duration > 0) {
        const progressWrapper = document.createElement('div');
        progressWrapper.className = 'notification-progress';
        const progressBar = document.createElement('div');
        progressBar.className = 'notification-progress-bar';
        progressBar.style.width = '100%';
        progressWrapper.appendChild(progressBar);
        content.appendChild(progressWrapper);
    }
    
    notif.appendChild(content);
    
    // Close button
    const closeBtn = document.createElement('div');
    closeBtn.className = 'notification-close';
    closeBtn.innerHTML = '×';
    closeBtn.onclick = (e) => {
        e.stopPropagation();
        closeNotification(id);
    };
    notif.appendChild(closeBtn);
    
    // Click to close
    notif.onclick = () => closeNotification(id);
    
    return notif;
}

// Notification bezárása
function closeNotification(id) {
    const notifObj = notifications.find(n => n.id === id);
    if (!notifObj) return;
    
    // Timeout törlése
    if (notifObj.timeout) {
        clearTimeout(notifObj.timeout);
    }
    
    // Closing animáció
    notifObj.element.classList.add('closing');
    
    // Eltávolítás animáció után
    setTimeout(() => {
        removeNotification(id);
    }, config.style.animationSpeed);
}

// Notification eltávolítása
function removeNotification(id) {
    const index = notifications.findIndex(n => n.id === id);
    if (index === -1) return;
    
    const notif = notifications[index];
    if (notif.element && notif.element.parentNode) {
        notif.element.parentNode.removeChild(notif.element);
    }
    
    notifications.splice(index, 1);
    
    // Callback FiveM-nek
    fetch(`https://${GetParentResourceName()}/notificationClosed`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: id })
    });
}

// Összes notification törlése
function clearAllNotifications() {
    notifications.forEach(notif => {
        if (notif.element && notif.element.parentNode) {
            notif.element.parentNode.removeChild(notif.element);
        }
        if (notif.timeout) {
            clearTimeout(notif.timeout);
        }
    });
    notifications = [];
}

// Persistent notification
function showPersistent(data) {
    const existing = persistentContainer.querySelector(`[data-id="${data.id}"]`);
    if (existing) {
        existing.parentNode.removeChild(existing);
    }
    
    const notif = document.createElement('div');
    notif.className = `persistent-notification ${data.type}`;
    notif.dataset.id = data.id;
    
    const icon = document.createElement('div');
    icon.className = 'notification-icon';
    icon.textContent = data.icon || '📌';
    notif.appendChild(icon);
    
    const content = document.createElement('div');
    content.className = 'notification-content';
    
    if (data.title) {
        const title = document.createElement('div');
        title.className = 'notification-title';
        title.textContent = data.title;
        content.appendChild(title);
    }
    
    const message = document.createElement('div');
    message.className = 'notification-message';
    message.textContent = data.message;
    content.appendChild(message);
    
    notif.appendChild(content);
    persistentContainer.appendChild(notif);
}

// Persistent notification eltávolítása
function removePersistent(id) {
    const notif = persistentContainer.querySelector(`[data-id="${id}"]`);
    if (notif) {
        notif.style.animation = 'fadeOut 0.3s ease-out';
        setTimeout(() => {
            if (notif.parentNode) {
                notif.parentNode.removeChild(notif);
            }
        }, 300);
    }
}

// Progress bar
function showProgress(data) {
    progressContainer.classList.remove('hidden');
    progressLabel.textContent = data.label || 'Loading...';
    progressBar.style.width = '0%';
    progressPercentage.textContent = '0%';
    
    const startTime = Date.now();
    const duration = data.duration;
    
    progressInterval = setInterval(() => {
        const elapsed = Date.now() - startTime;
        const percent = Math.min((elapsed / duration) * 100, 100);
        
        progressBar.style.width = percent + '%';
        progressPercentage.textContent = Math.floor(percent) + '%';
        
        if (percent >= 100) {
            clearInterval(progressInterval);
        }
    }, 50);
}

// Progress bar elrejtése
function hideProgress() {
    if (progressInterval) {
        clearInterval(progressInterval);
        progressInterval = null;
    }
    progressContainer.classList.add('hidden');
}

// Hang lejátszása
function playSound(soundName, volume = 0.3) {
    try {
        const audio = new Audio(`assets/sounds/${soundName}.ogg`);
        audio.volume = volume;
        audio.play().catch(err => {
            console.warn('Sound playback failed:', err);
        });
    } catch (err) {
        console.warn('Sound loading failed:', err);
    }
}

// Helper: Resource név lekérése
function GetParentResourceName() {
    return 'll-notify';
}

// ⇩ EZZEL HELYETTESÍTD
updateContainerPosition();

// Teljesen kikapcsoljuk az NUI fókuszt és kurzort
setTimeout(() => {
    SetNuiFocus(false, false);
}, 50);

// Biztonság kedvéért minden frame-ben (ha valami mégis aktiválja)
RegisterNuiCallbackType('notificationClosed');
on('__cfx_nui:notificationClosed', (data, cb) => {
    cb({});
});

setInterval(() => {
    SetNuiFocus(false, false);
}, 500);