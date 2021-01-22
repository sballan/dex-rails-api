import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

// @ts-ignore
import Rolodex from "rolodex_small.png"


export default class Home extends React.Component<any, any>{
    render() {

      return (
          <>
            <h1 className="title has-text-centered">Dex</h1>
              <img src={Rolodex}/>
          </>
        )
    }
}

