package com.nswebkit.plugins.chooselocation.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.amap.api.maps.AMapUtils;
import com.amap.api.maps.model.LatLng;
import com.amap.api.services.core.LatLonPoint;
import com.amap.api.services.core.PoiItemV2;
import com.amap.api.services.poisearch.PoiSearchV2;
import com.nswebkit.plugins.chooselocation.R;
import com.nswebkit.plugins.chooselocation.activity.NSMapLocationActivity;

import java.util.ArrayList;
import java.util.List;

/**
 * @date 2023/6/1 on 14:20 @author: neil
 */


public class NSRecyclerAdapter extends RecyclerView.Adapter<NSRecyclerAdapter.ViewHolder> {

    public enum NSRecyclerAdapterResultType {
        normalType,
        keywordType;
    }
    public interface NSRecyclerItemClickListener {
        void onItemClicked(int position, PoiItemV2 poiItemV2);

        void showResultTypeChanged(NSRecyclerAdapter.NSRecyclerAdapterResultType type);

        void selectedPOIChanged(PoiItemV2 selectedPOI);

    }


    private Context mContext;
    private ArrayList<PoiItemV2> data = new ArrayList<PoiItemV2>();
    private ArrayList<PoiItemV2> keywordData = new ArrayList<PoiItemV2>();//关键字搜索结果
    private NSRecyclerItemClickListener listener;
    public int normalTypePage = 1;
    public int keywordTypePage = 1;

    private int normalCurrentPosstion = 0;

    public LatLonPoint normalPOILocation;//当前搜索的POI经纬度

    private PoiItemV2 normalSelectedPOI;
    private PoiItemV2 keywordSelectedPOI;

    public LatLng gpsLocation;//gps 定位的经纬度

    public NSRecyclerAdapterResultType resultType = NSRecyclerAdapterResultType.normalType;

    public NSRecyclerAdapter(Context mContext, NSRecyclerItemClickListener listener) {
        this.mContext = mContext;
        this.listener = listener;
    }

    public void setResultType(NSRecyclerAdapterResultType type) {
        resultType = type;
        notifyDataSetChanged();
        listener.showResultTypeChanged(type);
        if (type == NSRecyclerAdapterResultType.normalType && normalSelectedPOI!=null) {
            listener.onItemClicked(normalCurrentPosstion, normalSelectedPOI);
        }

        listener.selectedPOIChanged(getCurrentPoi());
    }


    public PoiItemV2 getCurrentPoi(){
      if (resultType == NSRecyclerAdapterResultType.normalType) {
        return normalSelectedPOI;
      }
      else{
        return keywordSelectedPOI;
      }
    }
    public void addData(ArrayList<PoiItemV2> data) {
        if (this.data.size() == 0 && data.size() > 0) {
            normalSelectedPOI = data.get(0);
        }
        listener.selectedPOIChanged(getCurrentPoi());
        this.data.addAll(data);
        notifyDataSetChanged();
    }

    public void clearAllData() {
        this.data.clear();
        normalTypePage = 1;
        normalSelectedPOI = null;
        normalCurrentPosstion = 0;
        listener.selectedPOIChanged(getCurrentPoi());
        notifyDataSetChanged();
    }

    public void addKeywordData(ArrayList<PoiItemV2> data) {
        this.keywordData.addAll(data);
        notifyDataSetChanged();
    }

    public void clearAllKeywordData() {
        this.keywordData.clear();
        keywordTypePage = 1;
        keywordSelectedPOI = null;
        listener.selectedPOIChanged(getCurrentPoi());
        notifyDataSetChanged();
    }

    @Override
    public NSRecyclerAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        ViewHolder viewHolder = null;
        View convertView;
        convertView =
                LayoutInflater.from(mContext)
                        .inflate(R.layout.item_location, parent, false);
        viewHolder = new ViewHolder(convertView);
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        PoiItemV2 poiItem = null;
        if (resultType == NSRecyclerAdapterResultType.normalType) {
            poiItem = this.data.get(position);
            if (poiItem == normalSelectedPOI) {
                holder.item_selected.setVisibility(View.VISIBLE);
            } else {
                holder.item_selected.setVisibility(View.GONE);
            }
        } else {
            poiItem = this.keywordData.get(position);
            if (poiItem == keywordSelectedPOI) {
                holder.item_selected.setVisibility(View.VISIBLE);
            } else {
                holder.item_selected.setVisibility(View.GONE);
            }
        }

        if (gpsLocation == null){
            holder.detailTextView.setText( poiItem.getSnippet());
        }
        else{
            float distance = AMapUtils.calculateLineDistance(new LatLng(poiItem.getLatLonPoint().getLatitude(), poiItem.getLatLonPoint().getLongitude()), gpsLocation);

            String distanceStr = null;
            if (distance < 100) {
                distanceStr = "100米内";
            } else if (distance < 1000) {
                distanceStr = (int) distance + "米";
            } else {
                distanceStr = String.format("%.2f", distance / 1000) + "千米";
            }
            holder.detailTextView.setText(distanceStr + " | " + poiItem.getSnippet());
        }

        holder.textView.setText(poiItem.getTitle());

    }

    @Override
    public int getItemCount() {
        if (resultType == NSRecyclerAdapterResultType.normalType) {
            return this.data.size();
        }
        return this.keywordData.size();
    }

    class ViewHolder extends RecyclerView.ViewHolder {

        public ViewHolder(View itemView) {
            super(itemView);
            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    int currentPosition = getAdapterPosition();
                    if (resultType == NSRecyclerAdapterResultType.normalType) {
                        normalCurrentPosstion = currentPosition;
                        normalSelectedPOI = data.get(currentPosition);
                        listener.onItemClicked(currentPosition, data.get(currentPosition));
                    } else {
                        keywordSelectedPOI = keywordData.get(currentPosition);
                        listener.onItemClicked(currentPosition, keywordData.get(currentPosition));
                    }
                    listener.selectedPOIChanged(getCurrentPoi());

                    notifyDataSetChanged();
                }
            });
            textView = (TextView) itemView.findViewById(R.id.item_name);
            detailTextView = (TextView) itemView.findViewById(R.id.item_detail);
            item_selected = (ImageView) itemView.findViewById(R.id.item_selected);

        }

        TextView textView;
        TextView detailTextView;
        ImageView item_selected;
    }
}

