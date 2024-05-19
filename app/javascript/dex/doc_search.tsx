import React from 'react'


import _ from 'lodash'

// @ts-ignore
import Rolodex from "../images/rolodex.png"


export default class DocSearch extends React.Component<any, any>{
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
                  {this.state.matches.map(v => (
                    <li className="box">
                      <div className="level">
                        <div className="level-left">
                          <div>
                            <a className="is-size-5 has-text-link" href={v.url}>{v.title}  </a>
                            <p className="is-size-7 has-text-success">{v.url}</p>
                          </div>
                        </div>
                        <div className="level-right">
                          <div className="level-item">
                            <div>
                              <p>Rank: {v.rank?.toString().substring(0, 10)}</p>
                            </div>
                          </div>
                        </div>
                      </div>
                    </li>
                  ))}
                </ul>
          
              </div>
            </div>
          </>
        )
    }

  searchRequest(q = null) {
    q = q || this.state.searchText

    fetch('search_documents?' + new URLSearchParams({
      text: q
    }))
      .then(response => response.json())
      .then(data => {
        this.setState({matches: data.pages})
        console.log(data)
      });
  }

  handleInputChange(e) {
    this.setState({searchText: e.target.value});
  }

  handleInputSubmit(e) {
    e.preventDefault()
    this.props.history.push(`doc_search?q=${this.state.searchText}`)
    this.searchRequest()
  }
}

