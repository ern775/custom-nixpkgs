{
  freerdp = final: prev: {
    freerdp = prev.freerdp.override {
      withWaylandSupport = true;
      openh264 = null;
    };
  };
}
