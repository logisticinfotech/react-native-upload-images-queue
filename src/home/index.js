/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from "react";
import {
  Platform,
  StyleSheet,
  Text,
  View,
  CameraRoll,
  FlatList,
  Image,
  NativeModules,
  TouchableOpacity,
  Dimensions,
  Alert,
  requireNativeComponent,
  ActivityIndicator
} from "react-native";

const CompressImage = requireNativeComponent("CompressImage", null);
// import Spinner from "react-native-loading-spinner-overlay";

import { observable } from "mobx"; // For obeserver property
import { observer } from "mobx-react"; // For obeserver class

// Native Module
const compressImg = NativeModules.CompressImageManager;
let { width, height } = Dimensions.get("window");

@observer
export default class Home extends Component {
  constructor(props) {
    super(props);
    this.state = {
      images: [],
      uploadAll: false,
      uploadedImg: 0
    };
  }

  @observable visible = false;

  componentDidMount() {
    const fetchParams = {
      first: 25,
      assetType: "All"
    };
    CameraRoll.getPhotos({
      first: 20000000,
      assetType: "All"
    })
      .then(data => {
        const assets = data.edges;
        const images = assets.map(asset => asset.node.image);
        this.setState({
          images: images
        });
      })
      .catch(err => {
        console.log("Error :---->  ", err);
      });
  }

  // Replace element in array
  replaceAt(array, index, value) {
    const ret = array.slice(0);
    ret[index] = value;
    return ret;
  }

  // Upload All Images at a time
  onPressUploadAll = () => {
    if (this.state.uploadAll) {
      alert("Images are uploading Or All Image Already Uploaded...");
    } else {
      this.visible = true;
      this.setState({ uploadAll: true });
      let itemInd = 0;

      for (let index = 0; index < this.state.images.length; index++) {
        const element = this.state.images[index];
        this.onPressUploadImage(element, index);
      }
    }
  };

  // Upload specific Image to server
  async onPressUploadImage(item, index) {
    if (item.uploadStatus === true) {
      alert("Image Already Uploaded...");
    } else {
      let uploadResponse = await compressImg.fetchPhotos(item.uri);
      if (uploadResponse) {
        let newItem = Object.assign({ uploadStatus: true }, item);
        let imgArray = this.replaceAt(this.state.images, index, newItem);
        console.log(
          "Item Index :====> " +
            index +
            " Total Item :====> " +
            this.state.images.length +
            " Visible State :====> " +
            this.state.visible
        );
        if (index === this.state.images.length - 1) {
          this.visible = false;
        }
        this.setState(pre => {
          return { uploadAll: true, uploadedImg: pre.uploadedImg + 1 };
        });
        this.setState(pre => {
          return {
            images: imgArray,
            uploadedImg:
              pre.uploadedImg.length < imgArray.length
                ? pre.uploadedImg + 1
                : pre.uploadedImg
          };
        });
      }
    }
  }

  _renderItem = ({ item, index }) => (
    <View style={{ flexDirection: "row" }}>
      <Image
        style={[styles.image, { alignContent: "flex-start" }]}
        source={{ uri: item.uri }}
      />
    </View>
  );

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}> Welcome to React Native! </Text>

        <FlatList
          style={{ marginTop: 20, marginBottom: 20, width: "100%" }}
          data={this.state.images}
          extraData={this.state}
          keyExtractor={(item, index) => index}
          renderItem={this._renderItem}
          numColumns={3}
        />

        {this.state.uploadAll ? (
          <Text
            style={{
              fontSize: 17,
              color: "gray",
              alignContent: "flex-end",
              marginBottom: 20
            }}
          >
            {" "}
            Upload All ({this.state.uploadedImg}/{this.state.images.length})
          </Text>
        ) : (
          <TouchableOpacity
            style={{ alignContent: "flex-end" }}
            onPress={this.onPressUploadAll}
          >
            <Text
              style={{
                fontSize: 17,
                color: "black",
                alignContent: "flex-end",
                marginBottom: 20
              }}
            >
              {" "}
              Upload All{" "}
            </Text>
          </TouchableOpacity>
        )}

        {this.visible ? (
          <View style={styles.overlay}>
            <ActivityIndicator size="large" color="#F5FCFF" />
          </View>
        ) : null}
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#F5FCFF"
  },
  welcome: {
    fontSize: 20,
    textAlign: "center",
    margin: 20
  },
  instructions: {
    textAlign: "center",
    color: "#333333",
    marginBottom: 5
  },
  imageGrid: {
    flexDirection: "row",
    width: width / 3 - 30,
    height: width / 3 - 10,
    margin: 10
  },
  image: {
    width: 100,
    height: 100,
    margin: 10
  },
  overlay: {
    flex: 1,
    position: "absolute",
    left: 0,
    top: 0,
    opacity: 0.5,
    backgroundColor: "black",
    width: width,
    height: height,
    justifyContent: "center",
    alignItems: "center"
  }
});
