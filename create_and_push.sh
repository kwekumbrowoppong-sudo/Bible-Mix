#!/usr/bin/env bash
set -e

REPO_OWNER="kwekumbrowoppong-sudo"
REPO_NAME="bible-mix-prototype"
REPO_DESC="BIBLE MIX"
TOPICS='["bible","trivia","firebase","react","prototype"]'
DIR="${REPO_NAME}"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI not found. Install it and run 'gh auth login' first."
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "gh CLI not authenticated. Run 'gh auth login' and try again."
  exit 1
fi

if [ -d "$DIR" ]; then
  echo "Directory ${DIR} already exists. Please remove or choose a different location."
  exit 1
fi

mkdir "$DIR"
cd "$DIR"

# Create files
cat > README.md <<'README'
# Bible Mix — Trivia + Memory + Scramble (KJV) — Prototype

Prototype web app for a Mixed Bible game (Trivia, Verse Memory, Verse Scramble) targeting adults.
- Translation: KJV (public domain)
- Play mode: Anonymous play (no required auth). Local progress is stored in localStorage.
- Backend: Optional Firebase integration (Firestore, Hosting). Firebase is not required to run locally.

What’s included
- Vite + React app with Tailwind CSS
- Minimal mixed session engine: Trivia (MCQ), Memory (cloze), Scramble (word reorder)
- Seed data (KJV) under `src/data/seed.js`
- Optional Firebase integration scaffolding (`src/firebase.js`) and `firebase.json`

Getting started (local)
1. Install dependencies
   npm install

2. Run dev server
   npm run dev

3. Open http://localhost:5173

Optional: connect to Firebase
- Create a Firebase project, enable Hosting and Firestore if you want cloud persistence.
- (Optional) Enable Anonymous Authentication in Firebase Auth if you want cross-device anonymous persistence.
- Copy your Firebase config into `.env.local` (see `.env.example`).
- When ready, deploy:
  npm run build
  firebase deploy --only hosting

Files of interest
- src/data/seed.js — seed questions and verses (KJV)
- src/components — simple components implementing the three modes
- src/firebase.js — placeholder for Firebase initialization (disabled by default)
- src/utils/srs.js — simple SRS stub used by memory module (client-only)

Notes & next steps I can take for you
- Expand question bank (I can generate 100 trivia + 50 verses prepared for memory/scramble).
- Add Firebase-backed persistence for SRS & leaderboards (requires Firebase project info).
- Improve UI/UX, add accessibility, scoring, badges, and admin editor.

If you want, I can:
- Push this skeleton to a new GitHub repo for you (I’ll need repo details), or
- Generate a larger seed content pack (100 Trivia / 50 Verses), or
- Continue by wiring Firebase persistence for anonymous users.

Which option do you want me to do next?
README

cat > package.json <<'PKG'
{
  "name": "bible-mix-prototype",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint . --ext .js,.jsx"
  },
  "dependencies": {
    "firebase": "^10.11.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.0.0",
    "autoprefixer": "^10.4.14",
    "postcss": "^8.4.24",
    "tailwindcss": "^4.3.0",
    "vite": "^5.2.0"
  }
}
PKG

cat > vite.config.js <<'VITE'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
})
VITE

cat > tailwind.config.cjs <<'TWC'
module.exports = {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {},
  },
  plugins: [],
}
TWC

cat > postcss.config.cjs <<'POST'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
POST

cat > .env.example <<'ENV'
# Optional: Firebase config (if you enable cloud features)
VITE_FIREBASE_API_KEY=your_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
VITE_FIREBASE_APP_ID=your_app_id
ENV

cat > firebase.json <<'FIRE'
{
  "hosting": {
    "public": "dist",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      { "source": "**", "destination": "/index.html" }
    ]
  }
}
FIRE

mkdir -p src/components src/data

cat > src/main.jsx <<'MAIN'
import React from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import './styles.css'

createRoot(document.getElementById('root')).render(<App />)
MAIN

cat > src/App.jsx <<'APP'
import React, { useState } from 'react'
import seed from './data/seed'
import SessionEngine from './components/SessionEngine'

export default function App() {
  const [mode, setMode] = useState(null)

  return (
    <div className="min-h-screen bg-slate-50 text-slate-900 p-6">
      <div className="max-w-3xl mx-auto">
        <header className="mb-6">
          <h1 className="text-3xl font-bold">Bible Mix — Trivia · Memory · Scramble (KJV)</h1>
          <p className="mt-2 text-sm text-slate-600">
            Anonymous play · KJV · Firebase optional
          </p>
        </header>

        {!mode ? (
          <main className="space-y-4">
            <div className="bg-white p-6 rounded shadow">
              <h2 className="text-xl font-semibold">Quick Start</h2>
              <p className="mt-2 text-sm text-slate-600">
                Start a mixed session with trivia, memory and scramble items.
              </p>
              <div className="mt-4 flex gap-2">
                <button
                  onClick={() => setMode('mixed')}
                  className="px-4 py-2 bg-indigo-600 text-white rounded"
                >
                  Start Mixed Session
                </button>
                <button
                  onClick={() => setMode('custom')}
                  className="px-4 py-2 border rounded"
                >
                  Custom (dev)
                </button>
              </div>
            </div>

            <div className="bg-white p-6 rounded shadow">
              <h3 className="font-medium">Seed Data</h3>
              <p className="mt-2 text-sm text-slate-600">Loaded {seed.trivia.length} trivia, {seed.verses.length} verses, {seed.scrambles.length} scrambles.</p>
            </div>
          </main>
        ) : (
          <SessionEngine
            mode={mode}
            seed={seed}
            onExit={() => setMode(null)}
          />
        )}
      </div>
    </div>
  )
}
APP

cat > src/styles.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  font-family: ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
}
CSS

cat > src/data/seed.js <<'SEED'
// Seed data (KJV). Public domain.
const trivia = [
  {
    id: 't1',
    type: 'multiple_choice',
    category: 'Gospels',
    difficulty: 'medium',
    question: 'Who baptized Jesus?',
    options: [
      { id: 'a', text: 'Peter' },
      { id: 'b', text: 'John the Baptist' },
      { id: 'c', text: 'Paul' },
      { id: 'd', text: 'James' }
    ],
    answerId: 'b',
    reference: 'Matthew 3:13-17',
    explanation: 'John the Baptist baptized Jesus in the Jordan River.'
  },
  {
    id: 't2',
    type: 'multiple_choice',
    category: 'Epistles',
    difficulty: 'hard',
    question: 'According to Paul, who shall judge the secrets of men?',
    options: [
      { id: 'a', text: 'The elders' },
      { id: 'b', text: 'God' },
      { id: 'c', text: 'Angels' },
      { id: 'd', text: 'Jesus' }
    ],
    answerId: 'b',
    reference: 'Romans 2:16',
    explanation: 'Paul writes that God will judge the secrets of men by Jesus Christ.'
  },
  {
    id: 't3',
    type: 'multiple_choice',
    category: 'Acts',
    difficulty: 'medium',
    question: 'Which city did Lydia live in when she met Paul?',
    options: [
      { id: 'a', text: 'Philippi' },
      { id: 'b', text: 'Corinth' },
      { id: 'c', text: 'Thessalonica' },
      { id: 'd', text: 'Ephesus' }
    ],
    answerId: 'a',
    reference: 'Acts 16:13-15',
    explanation: 'Lydia was a seller of purple at Philippi; she and her household were baptized by Paul.'
  }
]

const verses = [
  {
    id: 'v1',
    reference: 'Philippians 4:13',
    text: 'I can do all things through Christ which strengtheneth me.'
  },
  {
    id: 'v2',
    reference: 'John 3:16',
    text: 'For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.'
  },
  {
    id: 'v3',
    reference: 'Romans 12:2',
    text: 'And be not conformed to this world: but be ye transformed by the renewing of your mind, that ye may prove what is that good, and acceptable, and perfect, will of God.'
  }
]

const scrambles = [
  {
    id: 's1',
    reference: 'Romans 12:2',
    text: 'And be not conformed to this world: but be ye transformed by the renewing of your mind,',
    // words array used for scramble UI
    words: 'And be not conformed to this world: but be ye transformed by the renewing of your mind,'.split(' ')
  },
  {
    id: 's2',
    reference: 'Philippians 4:13',
    text: 'I can do all things through Christ which strengtheneth me.',
    words: 'I can do all things through Christ which strengtheneth me.'.split(' ')
  }
]

export default {
  trivia,
  verses,
  scrambles
}
SEED

cat > src/components/SessionEngine.jsx <<'SE'
import React, { useEffect, useMemo, useState } from 'react'
import TriviaQuestion from './TriviaQuestion'
import MemoryCloze from './MemoryCloze'
import Scramble from './Scramble'

function pickMixed(seed, total = 12) {
  const pool = []
  // Mix proportions: 6 trivia, 4 memory, 2 scramble (if available)
  const tCount = Math.min(6, seed.trivia.length)
  const vCount = Math.min(4, seed.verses.length)
  const sCount = Math.min(2, seed.scrambles.length)
  pool.push(...seed.trivia.slice(0, tCount).map(i => ({ kind: 'trivia', item: i })))
  pool.push(...seed.verses.slice(0, vCount).map(i => ({ kind: 'memory', item: i })))
  pool.push(...seed.scrambles.slice(0, sCount).map(i => ({ kind: 'scramble', item: i })))
  // If not enough, pad with trivia
  while (pool.length < total && seed.trivia.length)
    pool.push({ kind: 'trivia', item: seed.trivia[Math.floor(Math.random()*seed.trivia.length)] })
  // shuffle
  for (let i = pool.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[pool[i], pool[j]] = [pool[j], pool[i]]
  }
  return pool.slice(0, total)
}

export default function SessionEngine({ mode, seed, onExit }) {
  const [index, setIndex] = useState(0)
  const [history, setHistory] = useState([])
  const rounds = useMemo(() => pickMixed(seed, 12), [seed])

  useEffect(() => {
    const saved = localStorage.getItem('bm_session')
    if (saved) {
      // do nothing now; fresh session by default
    }
  }, [])

  function record(result) {
    setHistory(h => [...h, result])
    setIndex(i => i + 1)
  }

  if (index >= rounds.length) {
    const score = history.filter(r => r.correct).length
    return (
      <div className="bg-white p-6 rounded shadow">
        <h2 className="text-xl font-semibold">Session Complete</h2>
        <p className="mt-2">Score: {score} / {rounds.length}</p>
        <div className="mt-4">
          <button onClick={() => { setIndex(0); setHistory([]) }} className="px-4 py-2 mr-2 border rounded">Play Again</button>
          <button onClick={onExit} className="px-4 py-2 bg-indigo-600 text-white rounded">Exit</button>
        </div>
      </div>
    )
  }

  const round = rounds[index]
  return (
    <div className="bg-white p-6 rounded shadow space-y-4">
      <div className="flex justify-between">
        <div>Round {index+1} / {rounds.length}</div>
        <div>Mode: {round.kind}</div>
      </div>

      {round.kind === 'trivia' && (
        <TriviaQuestion item={round.item} onResult={record} />
      )}
      {round.kind === 'memory' && (
        <MemoryCloze item={round.item} onResult={record} />
      )}
      {round.kind === 'scramble' && (
        <Scramble item={round.item} onResult={record} />
      )}
    </div>
  )
}
SE

cat > src/components/TriviaQuestion.jsx <<'TQ'
import React, { useState } from 'react'

export default function TriviaQuestion({ item, onResult }) {
  const [selected, setSelected] = useState(null)
  const [done, setDone] = useState(false)

  function submit() {
    const correct = selected === item.answerId
    setDone(true)
    onResult({ id: item.id, kind: 'trivia', correct })
  }

  return (
    <div>
      <h3 className="font-semibold">{item.question}</h3>
      <p className="text-sm text-slate-500">{item.reference}</p>
      <div className="mt-3 space-y-2">
        {item.options.map(o => (
          <label key={o.id} className={`block p-2 border rounded ${selected===o.id ? 'bg-indigo-50 border-indigo-300' : 'bg-white'}`}>
            <input type="radio" name="opt" checked={selected===o.id} onChange={() => setSelected(o.id)} className="mr-2" />
            {o.text}
          </label>
        ))}
      </div>
      <div className="mt-3">
        <button onClick={submit} disabled={!selected || done} className="px-4 py-2 bg-indigo-600 text-white rounded">Submit</button>
      </div>
      {done && (
        <div className="mt-3 p-3 rounded bg-slate-50 border">
          <div className="font-medium">Answer: {item.options.find(x=>x.id===item.answerId).text}</div>
          <div className="text-sm text-slate-600 mt-1">{item.explanation}</div>
        </div>
      )}
    </div>
  )
}
TQ

cat > src/components/MemoryCloze.jsx <<'MC'
import React, { useMemo, useState } from 'react'

function makeCloze(text, blanks = 0.25) {
  const words = text.split(' ')
  const count = Math.max(1, Math.floor(words.length * blanks))
  const idxs = new Set()
  while (idxs.size < count) {
    idxs.add(Math.floor(Math.random() * words.length))
  }
  return words.map((w, i) => idxs.has(i) ? '____' : w).join(' ')
}

export default function MemoryCloze({ item, onResult }) {
  const cloze = useMemo(() => makeCloze(item.text, 0.25), [item])
  const [answer, setAnswer] = useState('')
  const [done, setDone] = useState(false)
  const [correct, setCorrect] = useState(false)

  function submit() {
    // simple normalization
    const normalized = answer.replace(/\s+/g,' ').trim().toLowerCase()
    const target = item.text.replace(/\s+/g,' ').trim().toLowerCase()
    const ok = normalized === target || target.includes(normalized) // fuzzy allow
    setCorrect(ok)
    setDone(true)
    onResult({ id: item.id, kind: 'memory', correct: ok })
  }

  return (
    <div>
      <h3 className="font-semibold">Fill in the verse</h3>
      <p className="text-sm text-slate-500">{item.reference}</p>
      <div className="mt-3 p-3 bg-slate-50 rounded border">
        <div className="italic">{cloze}</div>
      </div>
      <textarea value={answer} onChange={(e)=>setAnswer(e.target.value)} rows={3} className="mt-3 w-full p-2 border rounded" placeholder="Type the full verse here..." />
      <div className="mt-3">
        <button onClick={submit} disabled={done} className="px-4 py-2 bg-indigo-600 text-white rounded">Submit</button>
      </div>
      {done && (
        <div className="mt-3 p-3 rounded bg-slate-50 border">
          <div className="font-medium">{correct ? 'Correct' : 'Not quite'}</div>
          <div className="text-sm text-slate-600 mt-1">{item.text}</div>
        </div>
      )}
    </div>
  )
}
MC

cat > src/components/Scramble.jsx <<'SCR'
import React, { useMemo, useState } from 'react'

function shuffle(arr) {
  const a = arr.slice()
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

export default function Scramble({ item, onResult }) {
  const words = item.words || item.text.split(' ')
  const [shuffled] = useState(() => shuffle(words))
  const [placed, setPlaced] = useState([])

  function pick(i) {
    setPlaced(p => [...p, shuffled[i]])
    // remove from shuffled view by cloning and replacing index with null
    // easier: mark by filter when rendering
  }

  function submit() {
    const attempt = placed.join(' ')
    const target = words.join(' ')
    const ok = attempt.trim() === target.trim()
    onResult({ id: item.id, kind: 'scramble', correct: ok })
  }

  return (
    <div>
      <h3 className="font-semibold">Scramble — reorder the words</h3>
      <p className="text-sm text-slate-500">{item.reference}</p>

      <div className="mt-3">
        <div className="mb-2 text-sm text-slate-600">Tap words to build the verse:</div>
        <div className="flex flex-wrap gap-2">
          {shuffled.map((w, i) => (
            <button
              key={i}
              onClick={() => pick(i)}
              disabled={placed.includes(w) && placed.filter(x=>x===w).length >= shuffled.filter(s=>s===w).length}
              className="px-2 py-1 border rounded text-sm bg-white"
            >
              {w}
            </button>
          ))}
        </div>
      </div>

      <div className="mt-3">
        <div className="p-3 bg-slate-50 border rounded min-h-[48px]">
          {placed.length === 0 ? <span className="text-slate-400">Selected words appear here...</span> : placed.join(' ')}
        </div>
      </div>

      <div className="mt-3">
        <button onClick={submit} className="px-4 py-2 bg-indigo-600 text-white rounded">Submit</button>
      </div>
    </div>
  )
}
SCR

cat > src/firebase.js <<'FB'
 // Optional Firebase initialization.
 // By default the app runs fully client-side with localStorage.
 // To enable Firebase, create a .env.local with your VITE_FIREBASE_... values and uncomment the initializeApp block.

import { initializeApp } from 'firebase/app'
import { getAuth } from 'firebase/auth'
import { getFirestore } from 'firebase/firestore'

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID
}

// Uncomment to initialize Firebase if you provided env vars
// const app = initializeApp(firebaseConfig)
// const auth = getAuth(app)
// const db = getFirestore(app)

// export { app, auth, db }
export { firebaseConfig }
FB

# Initialize git
git init
git checkout -b main
git add .
git commit -m "feat: initial prototype (trivia+memory+scramble)"

# Create GitHub repo and push
echo "Creating GitHub repository ${REPO_OWNER}/${REPO_NAME} ..."
gh repo create "${REPO_OWNER}/${REPO_NAME}" --public --description "${REPO_DESC}" --confirm

git branch -M main
git remote add origin "git@github.com:${REPO_OWNER}/${REPO_NAME}.git" || true
git push -u origin main

# Set topics via API
echo "Setting repository topics..."
gh api \
  -X PUT \
  -H "Accept: application/vnd.github.v3+json" \
  /repos/"${REPO_OWNER}"/"${REPO_NAME}"/topics \
  -f names="${TOPICS}"

echo
echo "Done. Repo created: https://github.com/${REPO_OWNER}/${REPO_NAME}"
echo "Next: cd ${DIR} && npm install && npm run dev"
