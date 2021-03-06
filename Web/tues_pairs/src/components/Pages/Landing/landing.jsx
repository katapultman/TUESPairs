import React from 'react';
import './style.scss';
import { Card, Button } from 'react-bootstrap';
import { Link, withRouter } from 'react-router-dom';
import * as ROUTES from '../../../constants/routes';
import GitHubIcon from '@material-ui/icons/GitHub';

const LandingPageBase = () => {
    return(
        <div className="landing-page">
            <Card bg="dark" style={{ width: '400px', height: '500px' }} className="landing-card">    
                <Card.Img
                    className="tues-pairs-logo"
                    src="https://firebasestorage.googleapis.com/v0/b/tuespairs.appspot.com/o/Logo_Text.png?alt=media&token=d787193b-09ef-468a-b6c8-034c1497e8c8"
                />
                <Card.Body className="landing-body">
                    <Card.Title className="perfect-pair">
                        Pairing up our favourite peers with their favourite teachers
                    </Card.Title>
                    <Link to={ROUTES.SIGN}>
                        <Button size="lg" variant="warning" className="continue-button">
                            Sign In
                        </Button>
                    </Link>
                    <div className="or-text">
                        <hr></hr>
                            <p>OR</p>
                        <hr></hr>
                    </div>
                    <Card.Subtitle className="perfect-pair">
                        Download Our Mobile App
                    </Card.Subtitle>
                    <Button href="https://github.com/katapultman/TUESPairs/releases" className="app-download" variant="secondary" size="lg" block>
                        <span className="github-icon"><GitHubIcon/></span>
                        <span className="github-text"> Latest release</span>
                    </Button>
                </Card.Body>
            </Card>
        </div>
    );
}

export default withRouter(LandingPageBase);