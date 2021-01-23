import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

// @ts-ignore
import Rolodex from "rolodex_small.png"


export default class Home extends React.Component<any, any>{
    render() {

      return (
          <>
            <div className="hero">
              <div className="hero-body">
                <div className="container has-text-centered">
                  <div className="title">
                    Dex
                  </div>
                  <div className="subtitle">
                    The World's Worst Search Engine
                  </div>

                  <figure className="image is-128x128 is-inline-block">
                    <img src={Rolodex} />
                  </figure>

                  <input type="text" className="input is-rounded"/>
                </div>
              </div>
            </div>
          </>
        )
    }
}

