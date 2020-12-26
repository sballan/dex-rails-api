import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import _ from 'lodash'

class SearchWithReact extends React.Component<any, any>{
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
            <form onSubmit={this.handleInputSubmit} >
                <input value={this.state.searchText} onChange={this.handleInputChange} />
            </form>

            <h2>Results</h2>

            <ul>
                {_.map(this.state.matches, (value, key) => (
                    <>
                        <h3>{key}</h3>
                        <ol>
                            {value.map(v => (
                              <li>
                                  Title: {v.page.title}     <br/>
                                  URL: {v.page.url}         <br/>
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
        </>)
    }

    searchRequest() {
        fetch('search_cache?' + new URLSearchParams({
            text: this.state.searchText
        }))
            .then(response => response.json())
            .then(data => {
                this.setState({
                    matches: data.matches
                })
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

document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(
        <SearchWithReact />,
        document.body.appendChild(document.createElement('div')),
    )
})

