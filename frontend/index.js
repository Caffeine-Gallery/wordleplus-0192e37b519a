import { backend } from 'declarations/backend';

const KEYBOARD_LAYOUT = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '←']
];

let state = {
    boardState: Array(6).fill('').map(() => Array(5).fill('')),
    currentRow: 0,
    currentTile: 0,
    gameStatus: 'IN_PROGRESS',
    targetWord: '',
    darkMode: localStorage.getItem('darkMode') === 'true'
};

let stats = JSON.parse(localStorage.getItem('wordleStats')) || {
    gamesPlayed: 0,
    gamesWon: 0,
    currentStreak: 0,
    maxStreak: 0,
    guessDistribution: Array(6).fill(0),
    lastPlayDate: null
};

function showLoader() {
    document.getElementById('loader').style.display = 'block';
}

function hideLoader() {
    document.getElementById('loader').style.display = 'none';
}

async function initGame() {
    showLoader();
    try {
        state.targetWord = await backend.getRandomWord();
        console.log("New game started");
        createBoard();
        createKeyboard();
        setupEventListeners();
        loadStats();
        applyTheme();
    } catch (error) {
        console.error("Error initializing game:", error);
        showToast("Error starting game. Please try again.");
    } finally {
        hideLoader();
    }
}

function createBoard() {
    const board = document.getElementById('game-board');
    board.innerHTML = '';
    
    for (let i = 0; i < 6; i++) {
        const row = document.createElement('div');
        row.className = 'row';
        for (let j = 0; j < 5; j++) {
            const tile = document.createElement('div');
            tile.className = 'tile';
            row.appendChild(tile);
        }
        board.appendChild(row);
    }
}

function createKeyboard() {
    const keyboard = document.getElementById('keyboard');
    const rows = keyboard.children;

    KEYBOARD_LAYOUT.forEach((row, i) => {
        rows[i].innerHTML = '';
        row.forEach(key => {
            const keyButton = document.createElement('button');
            keyButton.textContent = key;
            keyButton.className = 'key';
            if (key === 'ENTER') keyButton.classList.add('one-and-a-half');
            if (key === '←') {
                keyButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24"><path fill="var(--color-tone-1)" d="M22 3H7c-.69 0-1.23.35-1.59.88L0 12l5.41 8.11c.36.53.9.89 1.59.89h15c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H7.07L2.4 12l4.66-7H22v14zm-11.59-2L14 13.41 17.59 17 19 15.59 15.41 12 19 8.41 17.59 7 14 10.59 10.41 7 9 8.41 12.59 12 9 15.59z"></path></svg>';
                keyButton.classList.add('one-and-a-half');
            }
            rows[i].appendChild(keyButton);
        });
    });
}

function handleInput(key) {
    if (state.gameStatus !== 'IN_PROGRESS') return;

    if (key === '←' || key === 'Backspace') {
        if (state.currentTile > 0) {
            state.currentTile--;
            state.boardState[state.currentRow][state.currentTile] = '';
            updateBoard();
        }
    } else if (key === 'ENTER' || key === 'Enter') {
        if (state.currentTile === 5) {
            submitGuess();
        } else {
            showToast("Not enough letters");
        }
    } else if (/^[A-Z]$/.test(key) && state.currentTile < 5) {
        state.boardState[state.currentRow][state.currentTile] = key;
        state.currentTile++;
        updateBoard();
        animateTilePop(state.currentRow, state.currentTile - 1);
    }
}

function updateBoard() {
    const rows = document.getElementById('game-board').children;
    state.boardState.forEach((row, i) => {
        const tiles = rows[i].children;
        row.forEach((letter, j) => {
            tiles[j].textContent = letter;
            tiles[j].classList.toggle('filled', letter !== '');
        });
    });
}

async function submitGuess() {
    const guess = state.boardState[state.currentRow].join('');
    
    showLoader();
    try {
        const result = await backend.evaluateGuess(guess);
        console.log("Guess evaluation result:", result);

        if (result[0] === 'invalid') {
            showToast("Invalid word");
            shakeRow(state.currentRow);
            return;
        }

        animateReveal(state.currentRow, result);

        if (result.every(r => r === 'correct')) {
            setTimeout(() => {
                state.gameStatus = 'WIN';
                showToast(['Genius!', 'Magnificent!', 'Impressive!', 'Splendid!', 'Great!', 'Phew!'][state.currentRow]);
                updateStats(true);
                celebrateWin();
            }, 1500);
        } else if (state.currentRow === 5) {
            setTimeout(() => {
                state.gameStatus = 'LOSE';
                showToast(state.targetWord);
                updateStats(false);
            }, 1500);
        } else {
            state.currentRow++;
            state.currentTile = 0;
        }
    } catch (error) {
        console.error("Error submitting guess:", error);
        showToast("Error submitting guess. Please try again.");
    } finally {
        hideLoader();
    }
}

function animateTilePop(row, col) {
    const tile = document.getElementById('game-board').children[row].children[col];
    tile.classList.add('pop');
    setTimeout(() => tile.classList.remove('pop'), 100);
}

function animateReveal(row, result) {
    const tiles = document.getElementById('game-board').children[row].children;
    const keys = document.querySelectorAll('.key');
    
    result.forEach((type, i) => {
        setTimeout(() => {
            tiles[i].classList.add('flip-in');
            setTimeout(() => {
                tiles[i].classList.add(type);
                updateKeyboardColors(state.boardState[row][i], type);
                tiles[i].classList.remove('flip-in');
                tiles[i].classList.add('flip-out');
            }, 250);
        }, i * 250);
    });
}

function updateKeyboardColors(letter, type) {
    const keys = document.querySelectorAll('.key');
    keys.forEach(key => {
        if (key.textContent === letter) {
            key.classList.remove('correct', 'present', 'absent');
            key.classList.add(type);
        }
    });
}

function showToast(message) {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.classList.add('show');
    setTimeout(() => toast.classList.remove('show'), 2000);
}

function shakeRow(row) {
    const rowElement = document.getElementById('game-board').children[row];
    rowElement.classList.add('shake');
    setTimeout(() => rowElement.classList.remove('shake'), 500);
}

function celebrateWin() {
    const tiles = document.getElementById('game-board').children[state.currentRow].children;
    for (let i = 0; i < 5; i++) {
        setTimeout(() => {
            tiles[i].classList.add('win-animation');
        }, i * 100);
    }
}

function updateStats(won) {
    const today = new Date().toDateString();
    
    if (stats.lastPlayDate !== today) {
        stats.gamesPlayed++;
        if (won) {
            stats.gamesWon++;
            stats.currentStreak++;
            stats.maxStreak = Math.max(stats.maxStreak, stats.currentStreak);
            stats.guessDistribution[state.currentRow]++;
        } else {
            stats.currentStreak = 0;
        }
        stats.lastPlayDate = today;
        localStorage.setItem('wordleStats', JSON.stringify(stats));
        loadStats();
    }
}

function loadStats() {
    document.getElementById('gamesPlayed').textContent = stats.gamesPlayed;
    document.getElementById('winPercentage').textContent = 
        stats.gamesPlayed ? Math.round((stats.gamesWon / stats.gamesPlayed) * 100) : 0;
    document.getElementById('currentStreak').textContent = stats.currentStreak;
    document.getElementById('maxStreak').textContent = stats.maxStreak;
    updateDistributionChart();
}

function updateDistributionChart() {
    const distributionContainer = document.getElementById('guessDistribution');
    distributionContainer.innerHTML = '';

    const maxGuesses = Math.max(...stats.guessDistribution);

    stats.guessDistribution.forEach((count, index) => {
        const bar = document.createElement('div');
        bar.classList.add('distribution-bar');
        const label = document.createElement('span');
        label.textContent = `${index + 1}`;
        const countSpan = document.createElement('span');
        countSpan.textContent = count;
        const barFill = document.createElement('div');
        barFill.style.width = `${(count / maxGuesses) * 100}%`;
        barFill.style.backgroundColor = '#538d4e';
        
        bar.appendChild(label);
        bar.appendChild(countSpan);
        bar.appendChild(barFill);
        distributionContainer.appendChild(bar);
    });
}

function toggleTheme() {
    state.darkMode = !state.darkMode;
    localStorage.setItem('darkMode', state.darkMode);
    applyTheme();
}

function applyTheme() {
    document.body.classList.toggle('dark-theme', state.darkMode);
}

function setupEventListeners() {
    document.addEventListener('keydown', e => {
        handleInput(e.key.toUpperCase());
    });

    document.getElementById('keyboard').addEventListener('click', e => {
        if (e.target.classList.contains('key')) {
            handleInput(e.target.textContent);
        }
    });

    document.getElementById('settingsBtn').addEventListener('click', toggleTheme);

    const modals = document.querySelectorAll('.modal');
    const closeButtons = document.querySelectorAll('.close-modal');
    
    document.getElementById('statsBtn').addEventListener('click', () => {
        document.getElementById('statsModal').style.display = 'block';
    });

    document.getElementById('helpBtn').addEventListener('click', () => {
        document.getElementById('helpModal').style.display = 'block';
    });

    closeButtons.forEach(button => {
        button.addEventListener('click', () => {
            const modal = button.closest('.modal');
            modal.style.display = 'none';
        });
    });

    window.addEventListener('click', e => {
        if (e.target.classList.contains('modal')) {
            e.target.style.display = 'none';
        }
    });

    document.querySelector('.share-btn').addEventListener('click', shareResults);
}

function shareResults() {
    const rows = state.boardState.slice(0, state.currentRow + 1).map(row => {
        return row.map((_, i) => {
            const tile = document.getElementById('game-board').children[state.currentRow].children[i];
            if (tile.classList.contains('correct')) return '🟩';
            if (tile.classList.contains('present')) return '🟨';
            if (tile.classList.contains('absent')) return '⬛';
            return '⬜';
        }).join('');
    }).join('\n');

    const text = `Wordle ${stats.gamesPlayed} ${state.currentRow + 1}/6\n\n${rows}`;
    
    if (navigator.share) {
        navigator.share({ text });
    } else {
        navigator.clipboard.writeText(text)
            .then(() => showToast('Copied to clipboard!'))
            .catch(() => showToast('Failed to copy'));
    }
}

initGame();
