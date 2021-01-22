import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

import _ from 'lodash'

// @ts-ignore
import Rolodex from "rolodex_small.png"


export default class Home extends React.Component<any, any>{
  constructor(props) {
    super(props)
    this.state = {
      searchText: "",
      matches: []
    }

    this.handleInputChange = this.handleInputChange.bind(this);
    this.handleInputSubmit = this.handleInputSubmit.bind(this);
  }
  render() {

      return (
          <>
            <div className="section">
              <nav className="navbar is-transparent">
                <div className="navbar-brand">
                  <a className="navbar-item" href="/">
                    <img src={Rolodex} alt="Dex"/>
                  </a>
                  <div className="navbar-item">
                    <form onSubmit={this.handleInputSubmit} >
                      <input type="text" className="input is-rounded" value={this.state.searchText} onChange={this.handleInputChange}/>
                    </form>
                  </div>
                </div>
              </nav>

              <ul>
                {_.map(this.state.matches, (value, key) => (
                  <>
                    <h3>{key}</h3>
                    <ol>
                      {value.map(v => (
                        <li>
                          Title: {v.page.title}     <br/>
                          URL: {v.page.url}         <br/>
                          Rank: {v.page.rank?.toString().substring(0, 10)}  <br/>
                          Kind: {v.kind}            <br/>
                          Distance: {v.distance}    <br/>
                          Length: {v.length}        <br/>
                          Full: {v.full ? "true" : "false"}
                        </li>
                      ))}
                    </ol>
                  </>
                ))}
              </ul>
            </div>
          </>
        )
    }

  searchRequest() {
    fetch('search_cache?' + new URLSearchParams({
      text: this.state.searchText
    }))
      .then(response => response.json())
      .then(data => {
        const matches = _.mapValues(data.matches, arr => {
          const grouped = _.groupBy(arr, 'kind')
          let titleMatches = grouped['title'] || []
          let linkMatches = grouped['link'] || []
          let headerMatches = grouped['header'] || []

          titleMatches = _.sortBy(titleMatches, m => (m.distance + 1) / m.length)
          linkMatches = _.sortBy(linkMatches, m => (m.distance + 1) / m.length)
          headerMatches = _.sortBy(headerMatches, m => (m.distance + 1) / m.length)

          return _.flatten([titleMatches, linkMatches, headerMatches])
        })
        this.setState({matches})
        console.log(data)
      });
  }

  handleInputChange(e) {
    this.setState({searchText: e.target.value});
  }

  handleInputSubmit(e) {
    e.preventDefault()
    this.searchRequest()
  }
}

