import React, { Component } from 'react';
import { withAuthorization } from '../../Authentication';
import { withFirebase } from '../../Firebase';
import { compose } from 'recompose';
import { withCurrentUser } from '../../Authentication/context';
import * as ROUTES from '../../../constants/routes';
import { withRouter } from 'react-router-dom';
import { Col } from 'react-bootstrap';
import './style.scss'
import log from '../../../constants/logger';
import Loading from '../../../constants/loading';
import UserCard from '../../../constants/user_card';
import { Button } from 'semantic-ui-react';


const HomePage = () => (
    <MatchPage />
);

class UserList extends Component {
  constructor(props) {
    super(props);

    this.state = {
      loading: false,
      users: [],
      currentUser: this.props.authUser,
    };
  }

  onMatch = event => {
    const currentUser = this.state.currentUser;

    if(currentUser.matchedUserID == null) {
      currentUser.matchedUserID = event.target.value;

      this.props.firebase.db.collection("users").doc(currentUser.uid).set({
        matchedUserID: currentUser.matchedUserID
      }, {merge: true})
      .then(() => {
        this.props.authUser.matchedUserID = currentUser.matchedUserID;
        log.info("Received current user w/ id " + this.props.authUser.uid + " matched user id " + currentUser.matchedUserID);
        this.props.history.push(ROUTES.ALREADY_MATCHED_PAGE);
      })
      .catch(error => {
        log.error(error);
      });
    }
    event.preventDefault();
    
  }

  onSkip = event => {
    const currentUser = this.props.authUser;
    currentUser.skippedUserIDs.push(event.target.value);

    this.props.firebase.db.collection("users").doc(currentUser.uid).set({
      skippedUserIDs: currentUser.skippedUserIDs
    }, {merge: true})
    .catch(error => {
      log.error(error);
    });
  }

  componentDidMount() {
    this.setState({ loading: true });

    this.unsubscribe = this.props.firebase.users()
    .onSnapshot(snapshot => {
      let users = [];

      if(!snapshot.exists) {
        snapshot.forEach(doc => {
          let tags = [];
          doc.data().tagIDs.forEach(tag => {
            if(tag) {
              this.props.firebase.tag(tag).get()
                .then(inforamtion => { // TODO: fix typo
                  tags.push(inforamtion.data());
                })
            }
          });
          users.push({ ...doc.data(), uid: doc.id, tags: tags });
        });
      }

      this.setState({
        users,
        loading: false,
      });
    });

    if(this.state.currentUser.username == null) {
      this.props.history.push(ROUTES.USER_INFO);
    }

  }

  componentDidUpdate() {
    let currentUser = this.props.authUser;

    if(currentUser.uid) {
    this.props.firebase.user(currentUser.uid).get()
      .then(snapshot => {
          const currentUser = this.props.firebase.getUserFromSnapshot(snapshot);

          this.setState({ currentUser, loading: false });

          if(currentUser.matchedUserID) {
            log.info("Current user w/ id " + currentUser.uid + " matched user id " + currentUser.matchedUserID);
            this.props.history.push(ROUTES.ALREADY_MATCHED_PAGE)
          }

          if(currentUser.username == null) {
            log.info("Received current user w/ id " + currentUser.uid + " and null fields. Redirecting him to USER_INFO endpoint.");
            this.props.history.push(ROUTES.USER_INFO);
          }
      });
    }
  }

  componentWillUnmount() {
    this.unsubscribe();
  }

  render() {
    const { users, loading } = this.state;

    let mappedUsers = [];
    
    const currentUser = this.state.currentUser;

    for(let i = 0; i < users.length; i++) {
      if(currentUser.isTeacher !== users[i].isTeacher && 
        !currentUser.skippedUserIDs.includes(users[i].uid) &&
        (users[i].matchedUserID === null || users[i].matchedUserID === currentUser.uid) &&
        !users[i].skippedUserIDs.includes(currentUser.uid)){
        if(users[i].photoURL === null) {
          users[i].photoURL = "https://x-treme.com.mt/wp-content/uploads/2014/01/default-team-member.png";
        }
        mappedUsers.push(users[i]);
      }
    }
    

    
    return(
      <div className="match-page">
        { loading && <Loading /> }
        
        <div className="user-cards">
            {mappedUsers.map(user => (
              <Col xs={14} md={14}>
                <UserCard user={user} />
                <Button.Group>
                  <Button value={user.uid} onClick={this.onMatch} variant="dark" style={{width: '100%'}, {backgroundColor: 'rgb(252, 152, 0)'}}>Match</Button>
                  <Button.Or />
                  <Button value={user.uid} onClick={this.onSkip} variant="dark">Skip</Button>
                </Button.Group>
              </Col>
            ))}
      </div>
    </div>
    )
  }

}

const condition = authUser => !!authUser;

const MatchPage =  compose (
  withRouter,
  withFirebase,
  withCurrentUser
)(UserList);

export default withAuthorization(condition)(HomePage);

export { MatchPage };