import React from 'react'
import ReactDOM from 'react-dom'
import { HashRouter, Switch, Route } from "react-router-dom"
import 'bulma/css/bulma.css'

import Home from './dex/home'
import Search from './dex/search'

class Dex extends React.Component<any, any>{
    render() {
        return (
          <Switch>
            <Route path="/search" component={Search}></Route>
            <Route path="/" component={Home}></Route>
          </Switch>
        )
    }
}

document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(
        <HashRouter><Dex/></HashRouter>,
        document.body.appendChild(document.createElement('div')),
    )
})

