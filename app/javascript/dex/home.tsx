import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

// @ts-ignore
import Rolodex from "../images/rolodex.png"


export default class Home extends React.Component<any, any>{
  constructor(props) {
    super(props)
    this.state = {
      searchText: ""
    }

    this.handleInputChange = this.handleInputChange.bind(this);
    this.handleInputSubmit = this.handleInputSubmit.bind(this);
  }

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

              <form onSubmit={this.handleInputSubmit} >
                <input type="text" className="input is-rounded" value={this.state.searchText} onChange={this.handleInputChange}/>
              </form>
            </div>
          </div>
        </div>
      </>
    )
  }

  handleInputChange(e) {
    this.setState({searchText: e.target.value});
  }

  handleInputSubmit(e) {
    e.preventDefault()
    this.props.history.push(`doc_search?q=${this.state.searchText}`)
  }
}

