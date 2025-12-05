import React from "react";
import { Container, Row, Col } from "react-bootstrap";
import Sidebar from "../components/Sidebar";

const MainLayout = ({ children }) => {
  return (
    <Container fluid>
      <Row>
        <Col xs={2} className="p-0">
          <Sidebar />
        </Col>

        <Col xs={10} className="p-4">
          {children}
        </Col>
      </Row>
    </Container>
  );
};

export default MainLayout;
