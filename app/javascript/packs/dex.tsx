import React from 'react'
import ReactDOM from 'react-dom'

import Home from '../dex/home'

class Dex extends React.Component<any, any>{
    render() {
        return (
          <>
            <Home/>
          </>
        )
    }
}

document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(
        <Dex />,
        document.body.appendChild(document.createElement('div')),
    )
})

