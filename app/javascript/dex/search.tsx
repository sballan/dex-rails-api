import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

import _ from 'lodash'

// @ts-ignore
import Rolodex from "../images/rolodex.png"


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

  componentDidMount() {
    const params = new URLSearchParams(this.props.location.search)
    const q = params.get('q') || ""
    this.setState({searchText: q})
    this.searchRequest(q)
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

              <div>
                <ul>
                  {_.map(this.state.matches, (value, key) => (
                    <>
                      <h3 class="title is-3">{key}</h3>
                      <ul>
                        {value.map(v => (
                          <li className="box">
                            <div className="level">
                              <div className="level-left">
                                <div>
                                  <a className="is-size-5 has-text-link" href={v.page.url}>{v.page.title}  </a>
                                  <p className="is-size-7 has-text-success">{v.page.url}</p>
                                </div>
                              </div>
                              <div className="level-right">
                                <div className="level-item">
                                  <div>
                                    <p>Rank: {v.page.rank?.toString().substring(0, 10)}</p>
                                    <p>Match: {v.distance}, {v.length}</p>
                                  </div>
                                </div>
                                <div className="level-item">
                                  <div>
                                    <p>Kind: {v.kind} </p>
                                    <p>Full: {v.full ? "true" : "false"}</p>
                                  </div>
                                </div>
                              </div>
                            </div>
                          </li>
                        ))}
                      </ul>
                    </>
                  ))}
                </ul>
              </div>

            </div>
          </>
        )
    }

  searchRequest(q = null) {
    q = q || this.state.searchText

    fetch('search_cache?' + new URLSearchParams({
      text: q
    }))
      .then(response => response.json())
      .then(data => {
        const matches = _.mapValues(data.matches, arr => {
          const grouped = _.groupBy(arr, 'kind')
          let titleMatches = grouped['title'] || []
          let linkMatches = grouped['link'] || []
          let headerMatches = grouped['header'] || []
          let paragraphMatches = grouped['paragraph'] || []

          titleMatches = _.sortBy(titleMatches, m => (m.distance + 1) / m.length)
          linkMatches = _.sortBy(linkMatches, m => (m.distance + 1) / m.length)
          headerMatches = _.sortBy(headerMatches, m => (m.distance + 1) / m.length)
          paragraphMatches = _.sortBy(paragraphMatches, m => (m.distance + 1) / m.length)

          return _.flatten([titleMatches, linkMatches, headerMatches, paragraphMatches])
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
    this.props.history.push(`search?q=${this.state.searchText}`)
    this.searchRequest()
  }
}

