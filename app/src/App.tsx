import React from 'react';
import { Routes, Route, useLocation, useNavigate } from 'react-router-dom';

import PageHome from './pages/Home'
import PageHelp from './pages/Help'
import PageNotFound from './pages/NotFound'

import './App.scss';

const pages = [
  { name: 'home', title: '首页', component: PageHome, path: '/' },
  { name: 'help', title: '帮助', component: PageHelp, path: '/help' },
  { name: 'not-found', title: '', component: PageNotFound, path: '*' },
]

function App() {
  const location = useLocation()
  const navigate = useNavigate()
  const handleNavigate = (path: string) => {
    navigate(path, { replace: true })
  }
  
  return (
    <>
      <header className="app-header flex">
        <h1 className="title" onClick={() => handleNavigate('/')}>Proxor</h1>
        <ul className="navigations flex-1">
          {
            pages
              .filter((e) => ['home', 'not-found'].indexOf(e.name) < 0)
              .map((e) => (
                <li
                  key={e.name}
                  className={`navigations-item ${e.path === location.pathname ? 'active' : ''}`}
                  onClick={() => handleNavigate(e.path)}
                >{e.title}</li>
              ))
          }
        </ul>
      </header>
      <section className="app-body flex-1">
        <Routes>
          {
            pages.map((e) => (<Route key={e.name} path={e.path} element={<e.component />} />))
          }
        </Routes>
      </section>
      <footer className="app-footer">
        Copyright@yitimo.2022
      </footer>
    </>
  );
}

export default App;
